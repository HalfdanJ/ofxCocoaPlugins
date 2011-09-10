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
@synthesize kinectConnected, deviceChar, bus,adr, stop, kinectNumber, irEnabled, calibration2d, levelsLow, levelsHigh, coordWarper, colorEnabled;

- (id)init
{
    self = [super init];
    if (self) {        
        projPointCache[0] = nil;
        projPointCache[1] = nil;
        projPointCache[2] = nil;
        projPointCache[3] = nil;

        point2Cache[0] = nil;
        point2Cache[1] = nil;
        point2Cache[2] = nil;
        point2Cache[3] = nil;
        
        point3Cache[0] = nil;
        point3Cache[1] = nil;
        point3Cache[2] = nil;
        
        deviceChar = nil;
        connectionRefused = NO;
        coordWarper = nil;
        kinectConnected  = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)setCalibration2d:(BOOL) b{
    calibration2d = b;
    if(kinectConnected){
        
        [ self calculateMatrix];
    }
}

-(void) setup{
    NSLog(@"Setup instance");
    
    // if(irEnabled && !kinectConnected){
    if(!kinectConnected && irEnabled){
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
#ifdef FASTDEBUG
    connectionRefused = YES;
#else     
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
    if(colorEnabled){
        color.setup(&context);
    }
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
#endif
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
    if([self calibration2d]){
        return ofxPoint3f();
    } else {
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
}

-(ofxPoint3f) convertWorldToProjection:(ofxPoint3f) p{
    ofxPoint2f p2 = [self convertWorldToSurface:p];
    return [[self surface] convertToProjection:p2];
}


#pragma mark Calibration 


-(void) calculateMatrix{
    if([self calibration2d]){
        ofxPoint2f handles[4];
        ofxPoint2f projHandles[4];
        
        handles[0] = [self point2:0];
        handles[1] = [self point2:1];
        handles[3] = [self point2:2];
        handles[2] = [self point2:3];
        
        projHandles[0] = [self projPoint:0];
        projHandles[1] = [self projPoint:1];
        projHandles[3] = [self projPoint:2];	
        projHandles[2] = [self projPoint:3];	//on purpose that 2 and 3 are mirrored
        
        //Create the coordinate warper
        coordWarper = new coordWarping();        
        ofxPoint2f src[4];
        ofxPoint2f dst[4];    

        
        
        src[0].x = [self projPoint:0].x/[self surfaceAspect];;
        src[0].y = [self projPoint:0].y;
        src[1].x = [self projPoint:1].x/[self surfaceAspect];
        src[1].y = [self projPoint:1].y;
        src[2].x = [self projPoint:3].x/[self surfaceAspect];
        src[2].y = [self projPoint:3].y;
        src[3].x = [self projPoint:2].x/[self surfaceAspect];
        src[3].y = [self projPoint:2].y;    
        
        
        for(int i=0;i<4;i++){
            ofxPoint2f p = handles[i];
            dst[i].x = p.x ;
            dst[i].y = p.y ;
        }
        
        coordWarper->calculateMatrix(dst, src);
        
    } else {
        ofxVec2f v1, v2, v3;
        ofxPoint3f points[3];
        ofxPoint2f projHandles[3];
        
        points[0] = [self point3:0];
        points[1] = [self point3:1];
        points[2] = [self point3:2];
        
        projHandles[0] = [self projPoint:0];
        projHandles[1] = [self projPoint:1];
        projHandles[2] = [self projPoint:2];	
        
        //Relative vectors
        ofxVec3f bluePoint = (points[2]-points[0]);
        ofxVec3f redPoint = (points[1]-points[0]);  
        
        //Find first rotation quarternion to blue point
        rotationQuaternion.makeRotate(bluePoint, ofxVec3f(1,0,0));        
        bluePoint = bluePoint * rotationQuaternion;
        
        //rotate the redpoint relative to the blue rotation
        redPoint = redPoint*rotationQuaternion;
        
        v1 = ofxVec2f(redPoint.z,redPoint.y);
        v2 = ofxVec2f(0,1);
        
        //Calculate the red rotation
        angle1 = v1.angle(v2);        
        angle2 = (projHandles[1] - projHandles[0]).angle(ofxVec2f(0,-1));
        scale = 1.0/(points[1]-points[0]).length() ;
        
        
        //Create the coordinate warper
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
}


-(void) reset{
    [self setPoint3:0 coord:ofxPoint3f(0,0,0)];
    [self setPoint3:1 coord:ofxPoint3f(1,0,0)];
    [self setPoint3:2 coord:ofxPoint3f(0,1,0)];
    
    [self setPoint2:0 coord:ofxPoint2f(0.1,0.1)];
    [self setPoint2:1 coord:ofxPoint2f(0.9,0.1)];
    [self setPoint2:2 coord:ofxPoint2f(0.1,0.9)];
    [self setPoint2:3 coord:ofxPoint2f(0.9,0.9)];
    
    [self setProjPoint:0 coord:ofxPoint2f(0,0.00001)];
    [self setProjPoint:1 coord:ofxPoint2f([self surfaceAspect],0.000001)];
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
    if(point == 3){
        ofxVec2f v1 = [self projPoint:1] - [self projPoint:0];
        ofxVec2f v2 = [self projPoint:2] - [self projPoint:0];
        
        ofxVec2f v = v1+v2;
        return [self projPoint:0] + v;        
    }
    
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
    if(!kinectConnected){
        return ofxPoint2f();
    }
    if(calibration2d){
        switch (n) {
            case 0:
                return coordWarper->inversetransform (0,0)*ofxVec2f(640,480);        
                break;
            case 1:
                return coordWarper->inversetransform (1,0)*ofxVec2f(640,480);        
                break;
            case 2:
                return coordWarper->inversetransform (1,1)*ofxVec2f(640,480);        
                break;
            case 3:
                return coordWarper->inversetransform (0,1)*ofxVec2f(640,480);        
                break;
                
            default:
                break;
        }

    } else {
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

-(ofxImageGenerator *)getColorGenerator{
    return &color;
}
-(ofxOpenNIContext*) getOpenNIContext{
    return &context;
}

#pragma mark Keystoner

-(float) surfaceAspect{
    return 	[[[self surface] aspect] floatValue];
}


@end
