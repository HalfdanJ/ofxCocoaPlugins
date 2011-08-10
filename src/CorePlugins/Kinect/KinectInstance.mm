//
//  KinectObject.m
//  SeMinSkygge
//
//  Created by Se Min Skygge on 05/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KinectInstance.h"
#import "Kinect.h"

@implementation KinectInstance
@synthesize surface, kinectController;
@synthesize kinectConnected, deviceChar, bus,adr, stop, kinectNumber, irEnabled, calibration2d, levelsLow, levelsHigh, coordWarper;

- (id)init
{
    self = [super init];
    if (self) {        
        projPointCache[0] = nil;
        projPointCache[1] = nil;
        projPointCache[2] = nil;
        
        point2Cache[0] = nil;
        point2Cache[1] = nil;
        point2Cache[2] = nil;
        
        point3Cache[0] = nil;
        point3Cache[1] = nil;
        point3Cache[2] = nil;
        
        deviceChar = nil;
        connectionRefused = NO;
        coordWarper = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


-(void) setup{
    NSLog(@"Setup instance");
    
   // if(irEnabled && !kinectConnected){
     if(!kinectConnected){
        [self startContext];
    }
}

-(void) update:(NSDictionary *)drawingInformation{
    if(irEnabled && !kinectConnected && !connectionRefused){
        [self startContext];
       // depth.getXnDepthGenerator().StartGenerating();
    } 
    
    if(!irEnabled && kinectConnected && !connectionRefused){
        [self stopContext];
      //  depth.getXnDepthGenerator().StopGenerating();
    } 
    
    if(kinectConnected && !stop){
		context.update();
		depth.update();
		//users.update();	
        
    }

}

-(void)startContext{
    unsigned short vendor_id; 
    unsigned short product_id; 
    unsigned char _bus; 
    unsigned char address; 
    
    //   string connection_string = info.GetCreationInfo(); 
    //     transform (connection_string.begin (), connection_string.end (), connection_string.begin (), std::towlower);
    //     printf("vendor_id %i product_id %i bus %i address %i connection %s \n", vendor_id, product_id, bus, address, connection_string.c_str()); 
    
    
	//ofSetLogLevel(OF_LOG_VERBOSE);	
    depth.deviceInfoChar =  [deviceChar cStringUsingEncoding:NSUTF8StringEncoding];
    cout<<"Connect to "<<depth.deviceInfoChar <<endl;
	context.setup();
	kinectConnected = depth.setup(&context);
    ir.setup(&context);
    ir.levelsLow = levelsLow;
    ir.levelsHigh = levelsHigh;
    
    if(kinectConnected){
		//	users.setup(&context, &depth);		
        [self setDeviceChar:[NSString stringWithUTF8String:depth.deviceInfoChar]];
        sscanf(depth.deviceInfoChar, "%hx/%hx@%hhu/%hhu", &vendor_id,&product_id, &_bus, &address); 
        [self setBus:_bus];
        [self setAdr:address];

		[self calculateMatrix];	
        NSLog(@"Connected to kinect %@ bus %i adr %i",[NSString stringWithCString:depth.deviceInfoChar encoding:NSUTF8StringEncoding], [self bus], [self adr]);
        connectionRefused = NO;
	} else {
        connectionRefused = YES;
    }
} 

-(void)stopContext{
    context.getXnContext().Shutdown();
    kinectConnected = NO;
}





-(vector<ofxPoint3f>) getPointsInBoxXMin:(float)xMin xMax:(float)xMax yMin:(float)yMin yMax:(float)yMax zMin:(float)zMin zMax:(float)zMax res:(int)res{
    vector<ofxPoint3f> points;
    
    if(kinectConnected ){
        xn::DepthMetaData dmd;
        depth.getXnDepthGenerator().GetMetaData(dmd);	
        const XnDepthPixel* pixels = dmd.Data();
        
        
        for(int i=0;i<640*480;i+=res){
            int x = i % 640;
            int y = floor(i / 640);
            if(pixels[i] > 0){
                ofxPoint3f p = [self convertWorldToSurface:[self convertKinectToWorld:ofxPoint3f(x,y, pixels[i])]];
                if(p.x > xMin && p.x < xMax && p.y > yMin && p.y < yMax && p.z > zMin && p.z < zMax){
                    points.push_back(p);
                }
            }
        }
        
    }
    return points;	
    
}

#pragma mark Setters

-(void)setIrEnabled:(BOOL)_irEnabled{
    irEnabled = _irEnabled;
}

-(void)setLevelsLow:(float)_levelsLow{
    levelsLow = _levelsLow;
    ir.levelsLow = levelsLow;
}

-(void)setLevelsHigh:(float)_levelsHigh{
    levelsHigh = _levelsHigh;
    ir.levelsHigh = levelsHigh;
}



#pragma mark Conversion 


-(ofxPoint3f) convertKinectToWorld:(ofxPoint3f)p{
    if(!stop){
        XnPoint3D pIn;
        pIn.X = p.x;
        pIn.Y = p.y;
        pIn.Z = p.z;
        XnPoint3D pOut;
        
        depth.getXnDepthGenerator().ConvertProjectiveToRealWorld(1, &pIn, &pOut);
        
        return ofxPoint3f(pOut.X, pOut.Y, pOut.Z);
    } else {
        return nil;
    }
}

-(ofxPoint3f) convertWorldToKinect:(ofxPoint3f)p{
    if(!stop){
        XnPoint3D pIn;
        pIn.X = p.x;
        pIn.Y = p.y;
        pIn.Z = p.z;
        XnPoint3D pOut;
        
        depth.getXnDepthGenerator().ConvertRealWorldToProjective(1, &pIn, &pOut);
        
        return ofxPoint3f(pOut.X, pOut.Y, pOut.Z);
    } else {
        return nil;
    }
}

-(ofxPoint3f) convertWorldToSurface:(ofxPoint3f) p{
    p -= [self point3:0];	
    
    float rotatex,rotatey,rotatez,rotateval;
    rotationQuaternion.getRotate(rotateval, rotatex, rotatey, rotatez);
    
    p.rotate(rotateval*RAD_TO_DEG,ofxVec3f(rotatex, rotatey, rotatez));
    p.rotate(-angle1,ofxVec3f(1,0,0));
    
    
    float localScale = ([self projPoint:1] - [self projPoint:0]).length(); 
    p.z *= -scale*localScale;
    p.x *= scale*localScale;
    p.y *= -scale*localScale;
    
    p.rotate(-angle2, ofxVec3f(0,0,1));
    
    p += ofxPoint3f([self projPoint:0].x, [self projPoint:0].y,0 );
    
    return p;
}

-(ofxPoint3f) convertSurfaceToWorld:(ofxPoint3f) p{
    p -= ofxPoint3f([self projPoint:0].x, [self projPoint:0].y,0 );
    
    p.rotate(angle2, ofxVec3f(0,0,1));
    
    float localScale = ([self projPoint:1] - [self projPoint:0]).length(); 
    p.z /= -scale*localScale;
    p.x /= scale*localScale;
    p.y /= -scale*localScale;
    
    p.rotate(angle1,ofxVec3f(1,0,0));
    
    
    float rotatex,rotatey,rotatez,rotateval;
    rotationQuaternion.getRotate(rotateval, rotatex, rotatey, rotatez);
    p.rotate(-rotateval*RAD_TO_DEG,ofxVec3f(rotatex, rotatey, rotatez));
    
    p += [self point3:0];	
    
    return p;
    
}

-(ofxPoint3f) convertWorldToProjection:(ofxPoint3f) p{
    ofxPoint2f p2 = [self convertWorldToSurface:p];
    return [[self surface] convertToProjection:p2];
}


#pragma mark Calibration 


-(void) calculateMatrix{
    ofxVec2f v1, v2, v3;
    ofxPoint3f points[3];
    ofxPoint2f projHandles[3];
    
    points[0] = [self point3:0];
    points[1] = [self point3:1];
    points[2] = [self point3:2];
    
    projHandles[0] = [self projPoint:0];
    projHandles[1] = [self projPoint:1];
    projHandles[2] = [self projPoint:2];	
    
    ofxVec3f bluePoint = (points[2]-points[0]);
    ofxVec3f redPoint = (points[1]-points[0]);
    
    
    
    rotationQuaternion.makeRotate(bluePoint, ofxVec3f(1,0,0));
    
    bluePoint = bluePoint * rotationQuaternion;
    
   // cout<<bluePoint.x<<"  "<<bluePoint.y<<"  "<<bluePoint.z<<endl;
    
    
    redPoint = redPoint*rotationQuaternion;
    
    v1 = ofxVec2f(redPoint.z,redPoint.y);
    v2 = ofxVec2f(0,1);
    
    
    angle1 = v1.angle(v2);
    
    //!   [Prop(@"angle1") setFloatValue:angle1];
    
    angle2 = (projHandles[1] - projHandles[0]).angle(ofxVec2f(0,-1));
    //!   [Prop(@"angle2") setFloatValue:angle2];
    
    //rotationQuaternion.inverse();
    
    // cout<<redPoint.x<<"  "<<redPoint.y<<"  "<<redPoint.z<<endl;
    /*
     //Angle 1 er y akse rotation. Vinklen mellem de to blå akser (2)
     v1 = ofxVec2f(bluePoint.x,bluePoint.z);
     //	v2 = ofxVec2f((projHandles[2]-projHandles[0]).x,(projHandles[2]-projHandles[0]).y);	
     v3 = ofxVec2f(1,0);	
     float angle1 = -v1.angle(v3);
     
     
     bluePoint.rotate(angle1, ofxVec3f(0,1,0));
     redPoint.rotate(angle1, ofxVec3f(0,1,0));
     
     //Angle 2 er z akse rotation (roll). Den er fastdefineret i gulvspace
     v1 = ofxVec2f(bluePoint.x,bluePoint.y);
     v2 = ofxVec2f(1,0);	
     float angle2 = v1.angle(v2);
     
     
     bluePoint.rotate(angle2, ofxVec3f(0,0,1));
     redPoint.rotate(angle2, ofxVec3f(0,0,1));
     
     //Angle 3 er x akse rotation. 
     v1 = ofxVec2f(redPoint.z,redPoint.y);
     v2 = ofxVec2f(1,0);	
     float angle3 = v1.angle(v2);
     
     
     [Prop(@"angle1") setFloatValue:angle1];
     [Prop(@"angle2") setFloatValue:angle2];
     [Prop(@"angle3") setFloatValue:angle3];
     
     /*rotationMatrix.makeRotationMatrix( PropF(@"angle1")*DEG_TO_RAD, ofxVec3f(0,1,0),
     0, ofxVec3f(1,0,0),
     PropF(@"angle3")*DEG_TO_RAD, ofxVec3f(0,0,1));
     
     
     v2 = ofxVec2f(1,0);	
     //v3 = ofxVec2f((projHandles[1]-projHandles[0]).x,(projHandles[1]-projHandles[0]).y);	
     float angle2 = v1.angle(v2);	
     
     ofxVec3f dir = rotationMatrix.transform3x3(rotationMatrix,ofxVec3f(0,0,1));
     cout<<dir.x<<"  "<<dir.y<<"  "<<dir.z<<endl;*/
    
    /*
     rotationMatrix.makeRotationMatrix( PropF(@"angle1")*DEG_TO_RAD, ofxVec3f(0,1,0),
     -PropF(@"angle2")*DEG_TO_RAD, ofxVec3f(1,0,0),
     PropF(@"angle3")*DEG_TO_RAD, ofxVec3f(0,0,1));*/
    scale = 1.0/(points[1]-points[0]).length() ;
    
    if(coordWarper != nil){
     //   delete coordWarper;
    }
    coordWarper = new coordWarping();
    
    ofxPoint2f src[4];
    ofxPoint2f dst[4];    
    
    src[0].x = 0;
    src[0].y = 0;
    src[1].x = 1;
    src[1].y = 0;
    src[2].x = 1;
    src[2].y = 1;
    src[3].x = 0;
    src[3].y = 1;
    
    for(int i=0;i<4;i++){
        ofxPoint2f p = [self surfaceCorner:i];
        dst[i].x = p.x / 640;
        dst[i].y = p.y / 480;
    }
    
    coordWarper->calculateMatrix(dst, src);
}


-(void) reset{
    [self setPoint3:0 coord:ofxPoint3f(0,0,0)];
    [self setPoint3:1 coord:ofxPoint3f(1,0,0)];
    [self setPoint3:2 coord:ofxPoint3f(0,1,0)];
    
    [self setPoint2:0 coord:ofxPoint2f(0.1,0.1)];
    [self setPoint2:1 coord:ofxPoint2f(0.9,0.1)];
    [self setPoint2:2 coord:ofxPoint2f(0.1,0.9)];
    
    [self setProjPoint:0 coord:ofxPoint2f(0,0.1)];
    [self setProjPoint:1 coord:ofxPoint2f([self surfaceAspect],0.1)];
    [self setProjPoint:2 coord:ofxPoint2f(0,1)];
    
    if(kinectConnected){
    [self calculateMatrix];
    }
}

-(ofxPoint3f) point3:(int)point{
    return point3Cache[point];	
}
-(ofxPoint2f) point2:(int)point{
    return point2Cache[point];
}
-(ofxPoint2f) projPoint:(int)point{
    return projPointCache[point];
}

-(void) setPoint3:(int) point coord:(ofxPoint3f)coord{
    point3Cache[point] = coord;
}
-(void) setPoint2:(int) point coord:(ofxPoint2f)coord{
    point2Cache[point] = coord;
}
-(void) setProjPoint:(int) point coord:(ofxPoint2f)coord{
    projPointCache[point] = coord;
}

-(ofxPoint2f) surfaceCorner:(int)n{
    ofxPoint3f world;
    switch (n) {
        case 0:
            world = [self convertSurfaceToWorld:ofxPoint3f(0,0,0)];
            break;
        case 1:
            world = [self convertSurfaceToWorld:ofxPoint3f([self surfaceAspect],0,0)];
            break;
        case 2:
            world = [self convertSurfaceToWorld:ofxPoint3f([self surfaceAspect],1,0)];
            break;
        case 3:
            world = [self convertSurfaceToWorld:ofxPoint3f(0,1,0)];
            break;

        default:
            break;
    }

    return [self convertWorldToKinect:world];    
}

#pragma mark OpenNI getters 


-(ofxUserGenerator*) getUserGenerator{
    return &users;	
}

-(ofxDepthGenerator*) getDepthGenerator{
    return &depth;
}
-(ofxIRGenerator*) getIRGenerator{
    return &ir;
}
-(ofxOpenNIContext*) getOpenNIContext{
    return &context;
}

#pragma mark Keystoner

-(float) surfaceAspect{
    return 	[[[self surface] aspect] floatValue];
}


@end
