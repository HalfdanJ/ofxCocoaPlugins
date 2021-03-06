#ifdef KINECT

#import "Kinect.h"

#include <algorithm>


#include "TextureGrid.h"



//--------------------
//-- Kinect plugin --
//--------------------



@implementation Kinect
@synthesize instances, availableDevices;


-(id) initWithNumberKinects:(int)numberKinects{
    if([self init]){
#ifndef FASTDEBUG
        availableDevices = [NSMutableArray array];
        NSMutableDictionary * newDict = [NSMutableDictionary dictionary];
        [newDict setObject:[NSNumber numberWithBool:NO] forKey:@"available"];
        [newDict setObject:@"-" forKey:@"name"];
        [newDict setObject:@"" forKey:@"deviceChar"];
        [availableDevices addObject:newDict];
        
        //Enumerate all devices
        ofxOpenNIContext  context;
        context.setup();
        
        XnStatus result = XN_STATUS_OK;		
        unsigned short vendor_id; 
        unsigned short product_id; 
        unsigned char bus; 
        unsigned char address; 
        xn::NodeInfoList device_node_info_list;         
        result = context.getXnContext().EnumerateProductionTrees(XN_NODE_TYPE_DEVICE, NULL, device_node_info_list); 
        if (result != XN_STATUS_OK) { 
            printf("enumerating depth generators failed. Reason: %s\n", xnGetStatusString (result)); 
        } else { 
            for (xn::NodeInfoList::Iterator nodeIt =device_node_info_list.Begin(); nodeIt != device_node_info_list.End(); ++nodeIt) { 
                xn::NodeInfo deviceInfo = *nodeIt;
                const xn::NodeInfo& info = *nodeIt;
              /*  
                const XnProductionNodeDescription& description = info.GetDescription();
                printf("Image: vendor %s name %s instance %s\n",description.strVendor, description.strName, info.GetInstanceName());
                
                cout<<<<endl;*/
                cout<<info.GetCreationInfo()<<endl;
                sscanf(info.GetCreationInfo(), "%hx/%hx@%hhu/%hhu", &vendor_id,&product_id, &bus, &address); 
                string connection_string = info.GetCreationInfo(); 
                transform (connection_string.begin (), connection_string.end (), connection_string.begin (), std::towlower);
                
                newDict = [NSMutableDictionary dictionary];
                [newDict setObject:[NSNumber numberWithBool:YES] forKey:@"available"];
                [newDict setObject:[NSString stringWithFormat:@"Kinect %i",bus] forKey:@"name"];
                [newDict setObject:[NSString stringWithUTF8String:info.GetCreationInfo()] forKey:@"deviceChar"];
                [availableDevices addObject:newDict];                
            } 
        } 
        
        
#endif
        instances = [NSMutableArray arrayWithCapacity:numberKinects];
        for(int i=0;i<numberKinects;i++){
            KinectInstance * newInstance = [[KinectInstance alloc] init];
            [newInstance setKinectController:self];
            [newInstance setKinectNumber:i];
            [instances addObject:newInstance];           
        }
    }
    return self;
    
}

-(void)initPlugin{
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.5 minValue:0 maxValue:1] named:@"pointResolution"];
    
    for (int i=0; i<[instances count]; i++) {
        [self addProperty:[BoolProperty boolPropertyWithDefaultvalue:1.0] named:[NSString stringWithFormat:@"kinect%iEnabled",i]];
    }
    
    camCoord = ofVec3f(0,0,-5);
    eyeCoord = ofVec3f(0,0,0);
    
    draggedPoint = -1;
    
}

-(void)customPropertiesLoaded{		
    NSLog(@"Set Custom Properties: %@ %lu",customProperties,[[customProperties objectForKey:@"instances"] count]);
    int u=0;
    for(KinectInstance * kinect in instances){
        if([[customProperties objectForKey:@"instances"] count] > u){
            NSMutableDictionary * dict = [[customProperties objectForKey:@"instances"] objectAtIndex:u];
            [kinect setDeviceChar:[dict objectForKey:@"deviceChar"]];
            [kinect setSurface:[GetPlugin(Keystoner) getSurface:[dict objectForKey:@"surfaceName"] viewNumber:[[dict objectForKey:@"surfaceViewNumber"] intValue] projectorNumber:[[dict objectForKey:@"surfaceProjectorNumber"] intValue]]];
            [kinect setIrEnabled:[[dict objectForKey:@"irEnabled"] boolValue]];
            [kinect setLevelsHigh:[[dict objectForKey:@"levelHigh"] floatValue]];
            [kinect setLevelsLow:[[dict objectForKey:@"levelsLow"] floatValue]];
            
            for(int i=0;i<4;i++){
                [kinect setPoint2:i coord:
                 ofVec2f([[dict objectForKey:[NSString stringWithFormat:@"point%ia",i]] floatValue],
                            [[dict objectForKey:[NSString stringWithFormat:@"point%ib",i]] floatValue] )];
                
                [kinect setProjPoint:i coord:
                 ofVec2f([[dict objectForKey:[NSString stringWithFormat:@"projPoint%ix",i]] floatValue],
                            [[dict objectForKey:[NSString stringWithFormat:@"projPoint%iy",i]] floatValue] )];
            }
            
            for(int i=0;i<3;i++){
                [kinect setPoint3:i coord:
                 ofVec3f([[dict objectForKey:[NSString stringWithFormat:@"point%ix",i]] floatValue],
                            [[dict objectForKey:[NSString stringWithFormat:@"point%iy",i]] floatValue],
                            [[dict objectForKey:[NSString stringWithFormat:@"point%iz",i]] floatValue] )];
                
            }
            [kinect setCalibration2d:[[dict objectForKey:[NSString stringWithFormat:@"calibration2d"]] boolValue]];
            
        }
        u++;
    }
    
}

-(void)willSave{	//Read the settings of the selected cameras
	
	NSMutableDictionary * dict = customProperties;
	NSMutableArray * camerasArray = [NSMutableArray arrayWithCapacity:[instances count]];
	
	KinectInstance * kinect;
	for(kinect in instances){
        NSMutableDictionary * props = [NSMutableDictionary dictionary];
        
        if([kinect deviceChar] != nil){
            [props setObject:[kinect deviceChar] forKey:@"deviceChar"];
        }
        if([kinect surface] != nil){
            [props setObject:[[kinect surface] name] forKey:@"surfaceName"];
            [props setObject:[NSNumber numberWithInt:[[kinect surface] viewNumber]] forKey:@"surfaceViewNumber"];
            [props setObject:[NSNumber numberWithInt:[[kinect surface] projectorNumber]] forKey:@"surfaceProjectorNumber"];
            [props setObject:[NSNumber numberWithFloat:[kinect levelsLow]] forKey:@"levelsLow"];
            [props setObject:[NSNumber numberWithFloat:[kinect levelsHigh]] forKey:@"levelHigh"];
            [props setObject:[NSNumber numberWithBool:[kinect calibration2d]] forKey:@"calibration2d"];
            
            [props setObject:[NSNumber numberWithBool:[kinect irEnabled]] forKey:@"irEnabled"];
            
            for(int i=0;i<4;i++){
                [props setObject:[NSNumber numberWithFloat:[kinect point2:i].x] forKey:[NSString stringWithFormat:@"point%ia",i]];               
                [props setObject:[NSNumber numberWithFloat:[kinect point2:i].y] forKey:[NSString stringWithFormat:@"point%ib",i]];               
                
                [props setObject:[NSNumber numberWithFloat:[kinect projPoint:i].x] forKey:[NSString stringWithFormat:@"projPoint%ix",i]];               
                [props setObject:[NSNumber numberWithFloat:[kinect projPoint:i].y] forKey:[NSString stringWithFormat:@"projPoint%iy",i]];    
            }
            
            for(int i=0;i<3;i++){
                [props setObject:[NSNumber numberWithFloat:[kinect point3:i].x] forKey:[NSString stringWithFormat:@"point%ix",i]];               
                [props setObject:[NSNumber numberWithFloat:[kinect point3:i].y] forKey:[NSString stringWithFormat:@"point%iy",i]];               
                [props setObject:[NSNumber numberWithFloat:[kinect point3:i].z] forKey:[NSString stringWithFormat:@"point%iz",i]];               
            }
        }
        
        [camerasArray addObject:props];
		
		
		
	}
	
	[dict setObject:camerasArray forKey:@"instances"];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /*if(object == Prop(@"levelsIRLow")){
     ir.levelsLow = PropF(@"levelsIRLow");
     }
     if(object == Prop(@"levelsIRHigh")){
     ir.levelsHigh = PropF(@"levelsIRHigh");
     }
     */
    int i=0;
	KinectInstance * kinect;
	for(kinect in instances){
        if(object == Prop( ([NSString stringWithFormat:@"kinect%iEnabled",i]))  ){
            [kinect setIrEnabled:[object boolValue]];
        }
        i++;
    }
}



- (IBAction)setSelectedInstance:(id)sender {
    int i=0;
    [kinectDevicePopUp selectItemAtIndex:i];
    for(NSMutableDictionary * dict in availableDevices){
        if([[dict objectForKey:@"deviceChar"] isEqualToString:[[self getSelectedConfigureInstance] deviceChar]]){
            [kinectDevicePopUp selectItemAtIndex:i];
            break;
        }
        i++;
    }
    
    i=0;
    for(KeystoneSurface * surface in surfaces){
        if(surface == [[self getSelectedConfigureInstance] surface]){
            [surfacePopUp selectItemAtIndex:i];   
        }
        i++;
    }
    
    [instanceController setContent:[self getSelectedConfigureInstance]];
}

- (IBAction)changeDevice:(id)sender {
    [[self getSelectedConfigureInstance] setDeviceChar:[[availableDevices objectAtIndex:[kinectDevicePopUp indexOfSelectedItem]]valueForKey:@"deviceChar"] ];
}

- (IBAction)changeSurface:(id)sender {
    [[self getSelectedConfigureInstance] setSurface:[surfaces objectAtIndex:[surfacePopUp indexOfSelectedItem]]];
}



-(void) setup{
    handleImage = new ofImage();
    handleImage->loadImage([[[NSBundle mainBundle] pathForResource:@"handle" ofType:@"png"] cStringUsingEncoding:NSUTF8StringEncoding]);
    
    //Surface popup
    int w = [instanceSegmentedControl frame].size.width;
    w /= [instances count];
    w -= 2;
    
    [surfacePopUp removeAllItems];
    surfaces = [NSMutableArray array];
    Keystoner * keystoner = GetPlugin(Keystoner);
    for(KeystonerOutputview * output in [keystoner outputViews]){
        for(KeystoneProjector * proj in [output projectors]){
            for(KeystoneSurface * surface in [proj surfaces]){
                if([surface visible]){
                    [surfacePopUp addItemWithTitle:[NSString stringWithFormat:@"%@ - %i,%i", [surface name], [output viewNumber], [proj projectorNumber]]];
                    [surfaces addObject:surface];
                }
            }
        }
    }        
    [instanceSegmentedControl setSegmentCount:[instances count]];
    [instanceSegmentedControl setSelectedSegment:0];
    
    //Setup kinect instances
    int i=0;
    for(KinectInstance * instance in instances){
        if([instance point2:0] == nil)
            [instance reset];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [instanceSegmentedControl setLabel:[NSString stringWithFormat:@"Kinect %i",i] forSegment:i];
            [instanceSegmentedControl setWidth:w forSegment:i];
        });
        
        BOOL deviceFound = NO;
        for(NSMutableDictionary * dict in availableDevices){
            if([[dict objectForKey:@"deviceChar"] length] > 0 && [[instance deviceChar] length] > 0 &&  [[dict objectForKey:@"deviceChar"] isEqualToString:[instance deviceChar] ]){
                NSLog(@"Device found for kinect %i!", i);
                [instance setDeviceChar:[dict objectForKey:@"deviceChar"]];
                deviceFound = YES;
                break;
            }
        }
        if(!deviceFound && [instance deviceChar]){
            NSLog(@"Device not found for kinect %i deviceChar %@", i, [instance deviceChar]);
            [instance setIrEnabled:NO];
            
            if([instance bus] != 0){
                NSMutableDictionary * newDict = [NSMutableDictionary dictionary];
                [newDict setObject:[NSNumber numberWithBool:NO] forKey:@"available"];
                [newDict setObject:[NSString stringWithFormat:@"Kinect %i",[instance bus]] forKey:@"name"];
                [newDict setObject:[instance deviceChar] forKey:@"deviceChar"];
                [availableDevices addObject:newDict];
            }
        } 
        
        if(deviceFound){
            [instance setup];
        }
        
        
        
        
        i++;
    }
    
    //Populate the kinect device popup
    // dispatch_async(dispatch_get_main_queue(), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [kinectDevicePopUp removeAllItems];
        for(NSMutableDictionary * dict in availableDevices){
            [kinectDevicePopUp addItemWithTitle:[dict objectForKey:@"name"]];
        }
        
        
        
        int i = 0;
        NSArray *itemArray = [kinectDevicePopUp itemArray];
        NSDictionary *attributes = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSColor redColor], NSForegroundColorAttributeName,
                                    [NSFont systemFontOfSize: [NSFont systemFontSize]],
                                    NSFontAttributeName, nil];    
        NSLog(@"Availalbe devices %@",availableDevices);
        
        //        NSLog(@"popup devices %@",itemArray);
        /* for(NSMutableDictionary * dict in availableDevices){
         if(![[dict objectForKey:@"available"] boolValue] && i > 0){
         NSMenuItem *item = [itemArray objectAtIndex:i];
         NSAttributedString *as = [[NSAttributedString alloc] 
         initWithString:[item title]
         attributes:attributes];
         
         [item setAttributedTitle:as];
         }
         i++;
         }*/
        
        [self setSelectedInstance:self];
        
    });
}

-(void) update:(NSDictionary *)drawingInformation{
    
    //Update
    
    for(KinectInstance * instance in instances){
        [instance update:drawingInformation];
    }
    
	/*
     
     vector<ofxTrackedUser*> vusers = users.getFoundUsers(); 
     
     int numberNonstoredUsers = 0;
     
     bool dancerFound[3];
     for(int i=0;i<3;i++)
     dancerFound[i] = false;
     
     for(int i=0;i<vusers.size();i++){
     //------
     //Uncalibrated user
     if(vusers[i]->is_found && !vusers[i]->is_tracked){
     for(int p=1;p<4;p++){
     int dancer = -1;
     for(int d=0;d<3;d++){
     if(PropI(([NSString stringWithFormat:@"priority%i",d])) == p && dancers[i].state == 1){
     //Prioritering passer, og danseren har ikke nogen user tilknyttet, men har en calibration
     dancer = d;
     }
     }
     if(dancer >= 0){
     ofxTrackedUser * user = vusers[i];
     if(users.getXnUserGenerator().GetSkeletonCap().IsCalibrationData(dancer)){
     NSLog(@"Load calibration");
     users.stopPoseDetection(user->id);
     
     XnStatus status = users.getXnUserGenerator().GetSkeletonCap().LoadCalibrationData(user->id,dancer);
     users.startTracking(user->id);
     dancers[dancer].userId = user->id;
     if(!status){
     dancers[dancer].state = 2;
     }
     }						
     }
     }
     }
     
     //------
     //Calibrated user
     if(vusers[i]->is_tracked){
     bool matchingUser = NO;
     for(int j=0;j<3;j++){
     if(vusers[i]->id == dancers[j].userId){
     matchingUser = YES;
     dancerFound[j] = true;
     }
     }
     if(!matchingUser)
     numberNonstoredUsers++;
     }
     
     
     //			printf("User %i: Is Calibrating %i, is tracking %i \n",i, vusers[i]->is_calibrating, vusers[i]->is_tracked);
     //	printf("User %i:  \n",i);
     }
     */
    //------
    //Update gui
    
    /*	for(int j=0;j<3;j++){
     NSTextField * label;
     switch (j) {
     case 0:
     label = labelA;
     break;
     case 1:
     label = labelB;
     break;
     case 2:
     label = labelC;
     break;						
     default:
     break;
     }
     
     if(dancerFound[j] && dancers[j].state > 0){
     dancerFound[j] = true;
     dispatch_async(dispatch_get_main_queue(), ^{
     [label setStringValue:@"Tracking"];
     });
     dancers[j].state = 2;
     } else if(dancers[j].state > 0){
     dispatch_async(dispatch_get_main_queue(), ^{
     [label setStringValue:@"Searching"];	
     });
     dancers[j].state = 1;
     } else {
     dispatch_async(dispatch_get_main_queue(), ^{
     [label setStringValue:@"No calibration!"];	
     });
     }
     }
     
     dispatch_async(dispatch_get_main_queue(), ^{			
     if(numberNonstoredUsers == 1){
     [storeA setEnabled:true];
     [storeB setEnabled:true];
     [storeC setEnabled:true];
     } else {
     [storeA setEnabled:false];	
     [storeB setEnabled:false];	
     [storeC setEnabled:false];	
     }
     });*/
	//}
	
}

-(void) draw:(NSDictionary *)drawingInformation{
	if([drawCalibration state]){
        KinectInstance * kinect = [self getSelectedConfigureInstance];
        if([kinect kinectConnected]){
            
            //ApplySurface(@"Floor");
            glPushMatrix();
            [GetPlugin(Keystoner) applySurface:[kinect surface]];
            ofFill();
            
            ofVec2f corners[4];
            /* 
             corners[0] = [kinect convertSurfaceToWorld:ofVec3f(0,0,0)];
             corners[1] = [kinect convertSurfaceToWorld:ofVec3f([kinect surfaceAspect],0,0)];
             corners[2] = [kinect convertSurfaceToWorld:ofVec3f([kinect surfaceAspect],1,0)];
             corners[3] = [kinect convertSurfaceToWorld:ofVec3f(0,1,0)];        
             for(int i=0;i<4;i++){
             corners[i] = [kinect convertWorldToKinect:ofVec3f(corners[i])];
             }*/
            
            for(int i=0;i<4;i++){
                corners[i] = [kinect surfaceCorner:i];
            }
            //[kinect getIRGenerator]->generateTexture();
            ofTexture * tex = [kinect getIRGenerator]->getTexture();
            if([drawDepth state]){
                tex = [kinect getDepthGenerator]->getTexture();
            }
            ofSetColor(255, 255, 255,255);
            
            /*glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
            glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
            */
//                      texCoords[0] = ofVec2f(0.0,0.0);
//            texCoords[1] = ofVec2f(640,0.0);
//            texCoords[2] = ofVec2f(640,480);
//            texCoords[3] = ofVec2f(0.0,480);
//            
                     

         
            if([warpCalibration state]){                
                
                ofVec2f poly[4];
                
                poly[0] = ofVec2f(0.0,0.0);
                poly[1] = ofVec2f([kinect surfaceAspect],0.0);
                poly[2] = ofVec2f([kinect surfaceAspect],1.0);
                poly[3] = ofVec2f(0.0,1.0);
                

                TextureGrid texGrid;
                texGrid.drawTextureGrid(tex,  poly, corners, 10);
            } else {
                tex->bind();

                glBegin(GL_QUADS);
                glTexCoord2f(0,0);     glVertex3d(0, 0, 0);
                glTexCoord2f(640,0);   glVertex3d([kinect surfaceAspect], 0, 0);
                glTexCoord2f(640,480);   glVertex3d([kinect surfaceAspect], 1, 0);
                glTexCoord2f(0,480);   glVertex3d(0, 1, 0);
                glEnd();
                tex->unbind();
            }
                    
            
            
            //        [[self surface] apply];
            
            ofVec2f projHandles[4];	
            projHandles[0] = [kinect projPoint:0];
            projHandles[1] = [kinect projPoint:1];
            projHandles[2] = [kinect projPoint:2];
            projHandles[3] = [kinect projPoint:3];
            
            ofFill();
            //Y Axis 
            ofSetColor(0, 255, 0);
            ofCircle(projHandles[0].x,projHandles[0].y, 10/640.0);
            
            //X Axis
            ofSetColor(255, 0, 0);
            ofCircle(projHandles[1].x,projHandles[1].y, 10/640.0);
            ofLine(projHandles[0].x, projHandles[0].y, projHandles[1].x, projHandles[1].y);
            
            //Z Axis
            ofSetColor(0, 0, 255);
            ofCircle(projHandles[2].x,projHandles[2].y, 10/640.0);
            ofLine(projHandles[0].x, projHandles[0].y, projHandles[2].x, projHandles[2].y);
            
            ofSetColor(255, 255, 0);
            ofCircle(projHandles[3].x,projHandles[3].y, 10/640.0);
            
            
            [GetPlugin(Keystoner) popSurface];
        }
    }
    /*
     
     for(PersistentBlob * b in persistentBlobs){
     ofVec3f p = [b centroidFiltered];
     
     ofSetLineWidth(1);
     ofFill();
     ofSetColor(255, 255, 255);
     ofNoFill();
     ofCircle(p.x, p.z, 10.0/640);
     
     ofFill();
     ofSetColor(255, 255, 255,255*(1-p.y/300.0));
     ofCircle(p.x, p.z, 10.0/640);
     
     //			cout<<wfoot.x<<"  "<<wfoot.z<<endl;
     
     }
     
     ofVec3f kinect = [self convertWorldToSurface:ofVec3f(0,0,0)];
     
     ofVec3f lfoot, rfoot, lhand, rhand;
     if(users.getTrackedUsers().size() > 0){
     ofxTrackedUser * user = users.getTrackedUser(0);
     lfoot = [self convertWorldToSurface:user->left_lower_leg.worldEnd];
     rfoot = [self convertWorldToSurface:user->right_lower_leg.worldEnd];
     lhand = [self convertWorldToSurface:user->left_lower_arm.worldEnd];
     rhand = [self convertWorldToSurface:user->right_lower_arm.worldEnd];
     
     }
     
     {
     ofVec3f border0,border1, border2, border3;
     xn::DepthMetaData dmd;
     depth.getXnDepthGenerator().GetMetaData(dmd);
     
     XnPoint3D pIn[3];
     pIn[0].X = 0;
     pIn[0].Y = 240;
     pIn[0].Z = 4200;
     pIn[1].X = 320;
     pIn[1].Y = 240;
     pIn[1].Z = 4200;
     pIn[2].X = 640;
     pIn[2].Y = 240;
     pIn[2].Z = 4200;
     
     XnPoint3D pOut[3];				
     depth.getXnDepthGenerator().ConvertProjectiveToRealWorld(3, pIn, pOut);
     border0 = [self convertWorldToSurface:ofVec3f(0,0,0)];
     border1 = [self convertWorldToSurface:ofVec3f(pOut[0].X, pOut[0].Y, pOut[0].Z)];;
     border2 = [self convertWorldToSurface:ofVec3f(pOut[1].X, pOut[1].Y, pOut[1].Z)];
     border3 = [self convertWorldToSurface:ofVec3f(pOut[2].X, pOut[2].Y, pOut[2].Z)];
     
     ofSetColor(255, 0, 0);
     glBegin(GL_LINE_STRIP);
     glVertex2d(border0.x, border0.z);
     glVertex2d(border1.x, border1.z);
     glVertex2d(border2.x, border2.z);
     glVertex2d(border3.x, border3.z);
     glVertex2d(border0.x, border0.z);
     glEnd();
     }
     
     ofSetLineWidth(1);
     ofFill();
     ofSetColor(255, 255, 0);
     ofCircle(kinect.x, kinect.z, 10.0/640);
     
     ofEnableAlphaBlending();
     ofNoFill();
     ofSetColor(0, 255, 0, 255);
     ofCircle(lfoot.x, lfoot.z, 15.0/640);
     ofFill();
     ofSetColor(0, 255, 0, 255*(1-lfoot.y/500.0));
     ofCircle(lfoot.x, lfoot.z, 15.0/640);
     
     ofNoFill();
     ofSetColor(255, 0, 0, 255);
     ofCircle(rfoot.x, rfoot.z, 15.0/640);
     ofFill();
     ofSetColor(255, 0, 0, 255*(1-rfoot.y/500.0));
     ofCircle(rfoot.x, rfoot.z, 15.0/640);
     
     ofNoFill();
     ofSetColor(255, 255, 0, 255);
     ofCircle(lhand.x, lhand.z, 15.0/640);
     ofFill();
     ofSetColor(255, 255, 0, 255*(1-lhand.y/500.0));
     ofCircle(lhand.x, lhand.z, 15.0/640);
     
     
     ofNoFill();
     ofSetColor(0, 255, 244, 255);
     ofCircle(rhand.x, rhand.z, 15.0/640);
     ofFill();
     ofSetColor(0, 255, 255, 255*(1-rhand.y/500.0));
     ofCircle(rhand.x, rhand.z, 15.0/640);
     
     
     [GetPlugin(Keystoner) popSurface];
     
     }
     
     {
     glPushMatrix();
     [GetPlugin(Keystoner) applySurface:[self surface]];
     
     ofVec3f corners[4];
     corners[0] = [self convertSurfaceToWorld:ofVec3f(0,0,0)];
     corners[1] = [self convertSurfaceToWorld:ofVec3f(1,0,0)];
     corners[2] = [self convertSurfaceToWorld:ofVec3f(1,1,0)];
     corners[3] = [self convertSurfaceToWorld:ofVec3f(0,1,0)];
     
     for(int i=0;i<4;i++){
     corners[i] = [self convertWorldToKinect:ofVec3f(corners[i])];
     }
     
     ir.generateTexture();
     ofTexture * tex = ir.getTexture();
     ofSetColor(255, 255, 255,255);
     tex->bind();
     glBegin(GL_QUADS);
     glTexCoord2f(corners[0].x, corners[0].y);   glVertex3d(0, 0, 0);
     glTexCoord2f(corners[1].x, corners[1].y);   glVertex3d([self surfaceAspect], 0, 0);
     glTexCoord2f(corners[2].x, corners[2].y);   glVertex3d([self surfaceAspect], 1, 0);
     glTexCoord2f(corners[3].x, corners[3].y);   glVertex3d(0, 1, 0);
     glEnd();
     tex->unbind();
     
     [GetPlugin(Keystoner) popSurface];
     
     
     }
     */
}

-(void) controlDraw:(NSDictionary *)drawingInformation{
    //	ofBackground(0, 0, 0);
	
    KinectInstance * kinect = [self getSelectedConfigureInstance];
    if(![kinect kinectConnected]){
		ofSetColor(0, 0, 0);
		ofDrawBitmapString("Kinect not connected", 640/2-80, 480/2-8);
	} else {
		ofEnableAlphaBlending();
        bool calib2d = [kinect calibration2d];
        
        ofVec3f points[3];
        ofVec2f handles[4];
        ofVec2f projHandles[4];
        
        
        projHandles[0] = [kinect projPoint:0]; //The calibration markers on the surface
        projHandles[1] = [kinect projPoint:1];
        projHandles[2] = [kinect projPoint:2];
        projHandles[3] = [kinect projPoint:3];
        
        
        if(!calib2d){
            points[0] = [kinect point3:0]; //Used in 3d space
            points[1] = [kinect point3:1];
            points[2] = [kinect point3:2];
            
            handles[0] = [kinect point2:0]; //The ones to calibrate with
            handles[1] = [kinect point2:1];
            handles[2] = [kinect point2:2];
        } else {
            handles[0] = [kinect point2:0]; //The ones to calibrate with
            handles[1] = [kinect point2:1];
            handles[2] = [kinect point2:2];
            handles[3] = [kinect point2:3];
            
        }
		
        
        if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 0){
            glPushMatrix();{               
                //----------
                //Depth image	
                
                ofFill();
                ofSetColor(0, 0, 0,255);
                ofRect(0,0,320*2,240);
                ofSetColor(255, 255, 255);
                
                glPushMatrix();{
                    glScaled(0.5, 0.5, 1.0);
                    if([kinect colorEnabled]){
                    [kinect getColorGenerator]->draw();                        
                    } else {
                    [kinect getDepthGenerator]->draw();
                    }
                }glPopMatrix();
                
                
                glPushMatrix();{
                    ofNoFill();
                    //Y Axis 
                    ofSetColor(0, 255, 0);
                    //ofCircle(handles[0].x,handles[0].y, 10/640.0);
                    handleImage->draw(handles[0].x*320.0 - 13,handles[0].y*240.0 - 13, 25, 25);
                    
                    //X Axis
                    ofSetColor(255, 0, 0);
                    //                  ofCircle(handles[1].x,handles[1].y, 10/640.0);
                    ofLine(handles[0].x*320.0, handles[0].y*240.0, handles[1].x*320.0, handles[1].y*240.0);
                    handleImage->draw(handles[1].x*320.0 - 13,handles[1].y*240.0 - 13, 25, 25);
                    
                    
                    //Z Axis
                    ofSetColor(0, 0, 255);
                    // ofCircle(handles[2].x,handles[2].y, 10/640.0);
                    ofLine(handles[0].x*320.0, handles[0].y*240.0, handles[2].x*320.0, handles[2].y*240.0);
                    handleImage->draw(handles[2].x*320.0 - 13,handles[2].y*240.0 - 13, 25, 25);
                    
                    if(calib2d){
                        //4th
                        ofSetColor(255, 255, 255);
                        ofLine(handles[1].x*320.0, handles[1].y*240.0, handles[3].x*320.0, handles[3].y*240.0);
                        ofLine(handles[2].x*320.0, handles[2].y*240.0, handles[3].x*320.0, handles[3].y*240.0);
                        ofSetColor(255, 255, 0);
                        handleImage->draw(handles[3].x*320.0 - 13,handles[3].y*240.0 - 13, 25, 25);                        
                    }
                    
                    
                }glPopMatrix();
                ofSetColor(255, 255, 255);
                ofDrawBitmapString("Depthimage", 10, 14);
                
                
                //----------
                //IR image	
                glPushMatrix();{
                    glTranslated((640/2), 0, 0);
                    
                    glScaled(0.5, 0.5, 1.0);
                    [kinect getIRGenerator]->draw();
                }glPopMatrix();
                
                glPushMatrix();{
                    glTranslated((640/2), 0, 0);
                    
                    ofFill();
                    ofSetColor(0,255, 0,15);
                    glBegin(GL_QUADS);
                    for(int i=0;i<4;i++){
                        ofVec2f p = [kinect surfaceCorner:i];
                        glVertex2f(p.x*0.5,p.y*0.5);
                    }
                    glEnd();
                    
                    ofSetColor(0,255, 0,30);
                    glBegin(GL_LINE_STRIP);
                    for(int i=0;i<4;i++){
                        ofVec2f p = [kinect surfaceCorner:i];
                        glVertex2f(p.x*0.5,p.y*0.5);
                    }
                    ofVec2f p = [kinect surfaceCorner:0];
                    glVertex2f(p.x*0.5,p.y*0.5);
                    glEnd();
                    
                    
                    ofNoFill();
                    
                    //Y Axis 
                    ofSetColor(0, 255, 0);
                    handleImage->draw(handles[0].x*320.0 - 13,handles[0].y*240.0 - 13, 25, 25);
                    
                    //X Axis
                    ofSetColor(255, 255, 255);
                    ofLine(handles[0].x*320.0, handles[0].y*240.0, handles[1].x*320.0, handles[1].y*240.0);
                    ofSetColor(255, 0, 0);
                    handleImage->draw(handles[1].x*320.0 - 13,handles[1].y*240.0 - 13, 25, 25);
                    
                    //Z Axis
                    ofSetColor(255, 255, 255);                    
                    ofLine(handles[0].x*320.0, handles[0].y*240.0, handles[2].x*320.0, handles[2].y*240.0);
                    ofSetColor(0, 0, 255);
                    handleImage->draw(handles[2].x*320.0 - 13,handles[2].y*240.0 - 13, 25, 25);
                    
                    if(calib2d){
                        //4th
                        ofSetColor(255, 255, 255);
                        ofLine(handles[1].x*320.0, handles[1].y*240.0, handles[3].x*320.0, handles[3].y*240.0);
                        ofLine(handles[2].x*320.0, handles[2].y*240.0, handles[3].x*320.0, handles[3].y*240.0);
                        ofSetColor(255, 255, 0);
                        handleImage->draw(handles[3].x*320.0 - 13,handles[3].y*240.0 - 13, 25, 25);                        
                    }
                    
                    
                }glPopMatrix();
                
                ofSetColor(255, 255, 255);
                ofDrawBitmapString("IR", (640/2)+10, 14);
                
                //----------
                //Projectionview
                glPushMatrix();{
                    ofFill();
                    
                    glTranslated(0, 480/2, 0);
                    glScaled((640/2), (480/2), 1);
                    glScaled(640/480, 1, 1);
                    ofSetColor(0,0,0);
                    ofRect(0,0,1,1);
                    
                    glTranslated(0.5, 0.5, 0);
                    
                    float aspect = [kinect surfaceAspect];
                    ofSetColor(70, 70, 70);
                    if(aspect < 1){
                        glTranslated(-aspect/2, -0.5, 0);
                    } else {
                        glTranslated(-0.5, -(1.0/aspect)/2.0, 0);
                        glScaled(1.0/aspect, 1.0/aspect, 1);
                    }
                    
                    ofRect(0,0,aspect, 1);
                    ofNoFill();
                    ofSetColor(120, 120, 120);
                    ofRect(0,0,aspect, 1);
                    
                    glScaled(1.0/320.0, 1.0/240.0, 1.0);
                    
                    ofFill();
                    //Y Axis 
                    ofSetColor(0, 255, 0);
                    handleImage->draw(projHandles[0].x*320.0 - 13,projHandles[0].y*240.0 - 13, 25, 25);
                    
                    //X Axis
                    ofSetColor(255, 0, 0);
                    handleImage->draw(projHandles[1].x*320.0 - 13,projHandles[1].y*240.0 - 13, 25, 25);
                    ofLine(projHandles[0].x*320.0, projHandles[0].y*240.0 , projHandles[1].x*320.0, projHandles[1].y*240.0 );
                    
                    //Z Axis
                    ofSetColor(0, 0, 255,100);
                    ofNoFill();
                    handleImage->draw(int(projHandles[2].x*320.0) - 13,int(projHandles[2].y*240.0) - 13, 25, 25);
                    ofLine(projHandles[0].x*320.0, projHandles[0].y*240.0 , projHandles[2].x*320.0, projHandles[2].y*240.0 );
                    
                    //4th point
                    ofSetColor(255, 255, 0,100);
                    ofNoFill();
                    handleImage->draw(int(projHandles[3].x*320.0) - 13,int(projHandles[3].y*240.0) - 13, 25, 25);
                    //                    ofLine(projHandles[0].x*320.0, projHandles[0].y*240.0 , projHandles[3].x*320.0, projHandles[2].y*240.0 );
                    
                    
                    
                }glPopMatrix();
                ofSetColor(255, 255, 255);
                ofDrawBitmapString("Surfacespace - Place handles", 10, 480/2+14);
                
                /*
                 //----------
                 //Top view
                 glPushMatrix();{
                 glTranslated((640/2), 480/2, 0);
                 glScaled((640/2), (480/2), 1);
                 
                 glTranslated(0.5, 0, 0);
                 glScaled(1.0/4000.0, 1.0/4000.0, 1);
                 
                 ofFill();
                 //Y Axis 
                 ofSetColor(0, 255, 0);
                 ofCircle(points[0].x,points[0].z, 2000*10/640.0);
                 
                 //X Axis
                 ofSetColor(255, 0, 0);
                 ofCircle(points[1].x,points[1].z, 2000*10/640.0);
                 ofLine(points[0].x, points[0].z, points[1].x, points[1].z);
                 
                 //Z Axis
                 ofSetColor(0, 0, 255);
                 ofCircle(points[2].x,points[2].z, 2000*10/640.0);
                 ofLine(points[0].x, points[0].z, points[2].x, points[2].z);
                 
                 }glPopMatrix();
                 ofSetColor(255, 255, 255);
                 ofDrawBitmapString("TOP - Kinect world", (640/2)+10, 10+480/2);
                 
                 
                 }glPopMatrix();*/
                
                
                /* ofSetColor(255, 255, 255);
                 ofLine((640/2), 0, (640/2), 480);
                 ofLine(0, (480/2), 640, (480/2));	
                 ofLine(0, (480), 640, (480));				
                 */
            } glPopMatrix();
            
            
            
            //---------------------------------------------------------------------------------------------	
            
        } else if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 1) {
            //    glEnable(GL_DEPTH);
            glEnable(GL_DEPTH_TEST);
            glDepthFunc(GL_LEQUAL);
            glClearDepth(1.0); 
            
            
            ofFill();
            ofBackground(0,0,0);
            
            //  ofRect(0,0,640,640);
            
            glPushMatrix();{
                glScaled(640,640, 640);
                glTranslated(0.5,0.5,0);
                ofVec3f v = eyeCoord-camCoord;
                float a1 = ofVec2f(0, 1).angle(ofVec2f(eyeCoord.x, eyeCoord.z)-ofVec2f(camCoord.x, camCoord.z));    
                v.rotate(a1, ofVec3f(0,1,0));    
                float a2 = ofVec2f(1, 0).angle(ofVec2f(v.z,v.y));
                glRotated(a2, 1, 0, 0);
                glRotated(a1, 0, 1, 0);
                glTranslated(camCoord.x, camCoord.y,camCoord.z);
                
                glPushMatrix();{
                    glTranslated(-[kinect surfaceAspect]*0.5, -0.5, 0);
                    
                    
                    //Surface
                    
                    ofVec3f corners[4];
                    corners[0] = [kinect convertSurfaceToWorld:ofVec3f(0,0,0)];
                    corners[1] = [kinect convertSurfaceToWorld:ofVec3f([kinect surfaceAspect],0,0)];
                    corners[2] = [kinect convertSurfaceToWorld:ofVec3f([kinect surfaceAspect],1,0)];
                    corners[3] = [kinect convertSurfaceToWorld:ofVec3f(0,1,0)];
                    
                    for(int i=0;i<4;i++){
                        corners[i] = [kinect convertWorldToKinect:ofVec3f(corners[i])];
                    }
                    
                    [kinect getIRGenerator]->generateTexture();
                    ofTexture * tex = [kinect getIRGenerator]->getTexture();
                    ofSetColor(255, 255, 255,255);
                    tex->bind();
                    glBegin(GL_QUADS);
                    glTexCoord2f(corners[0].x, corners[0].y);     glVertex3d(0, 0, 0);
                    glTexCoord2f(corners[1].x, corners[1].y);   glVertex3d([kinect surfaceAspect], 0, 0);
                    glTexCoord2f(corners[2].x, corners[2].y);   glVertex3d([kinect surfaceAspect], 1, 0);
                    glTexCoord2f(corners[3].x, corners[3].y);   glVertex3d(0, 1, 0);
                    glEnd();
                    tex->unbind();
                    
                    //Handles
                    glPushMatrix();{
                        //Y Axis 
                        ofSetColor(0, 255, 0);
                        glScaled(1.0/320.0, 1.0/240.0,1.0);
                        handleImage->draw(projHandles[0].x*320.0 - 13,projHandles[0].y*240.0 - 13, 25, 25);
                        
                        ofSetColor(255, 0, 0);
                        handleImage->draw(projHandles[1].x*320.0 - 13,projHandles[1].y*240.0 - 13, 25, 25);
                        
                        ofSetColor(0, 0, 255);
                        handleImage->draw(projHandles[2].x*320.0 - 13,projHandles[2].y*240.0 - 13, 25, 25);                        
                    }glPopMatrix();
                    
                    //Kinect
                    ofVec3f p1 = [kinect convertWorldToSurface:points[0]];		
                    ofVec3f p2 = [kinect convertWorldToSurface:points[1]];		
                    ofVec3f p3 = [kinect convertWorldToSurface:points[2]];	
                    
                    
                    XnPoint3D pIn[5];
                    for(int i=0;i<5;i++){
                        pIn[i].Z = 4200;
                    }
                    pIn[0].X = 0;
                    pIn[0].Y = 0;                    
                    pIn[1].X = 640;
                    pIn[1].Y = 0;
                    pIn[2].X = 640;
                    pIn[2].Y = 480;
                    pIn[3].X = 0;
                    pIn[3].Y = 480;
                    pIn[4].X = 320;
                    pIn[4].Y = 240;
                    
                    
                    XnPoint3D pOut[5];				
                    [kinect getDepthGenerator]->getXnDepthGenerator().ConvertProjectiveToRealWorld(5, pIn, pOut);
                    
                    ofVec3f border[6];
                    border[0] = [kinect convertWorldToSurface:ofVec3f(0,0,0)];
                    for(int i=0;i<5;i++){
                        border[i+1] = [kinect convertWorldToSurface:ofVec3f(pOut[i].X, pOut[i].Y, pOut[i].Z)];;
                    }
                    
                    ofSetColor(100, 100, 100,80);
                    glBegin(GL_LINES);
                    for(int i=0;i<4;i++){
                        glVertex3d(border[0].x, border[0].y, border[0].z);
                        glVertex3d(border[i+1].x, border[i+1].y, border[i+1].z);
                    }
                    glColor3f(0,255,0);
                    glVertex3d(border[0].x, border[0].y, border[0].z);
                    glVertex3d(p1.x, p1.y, p1.z);
                    glColor3f(255,0,0);
                    glVertex3d(border[0].x, border[0].y, border[0].z);
                    glVertex3d(p2.x, p2.y, p2.z);
                    glColor3f(0,0,255);
                    glVertex3d(border[0].x, border[0].y, border[0].z);
                    glVertex3d(p3.x, p3.y, p3.z);
                    
                    glColor3f(255,255,255);
                    glVertex3d(border[0].x, border[0].y, border[0].z);
                    glVertex3d(border[5].x, border[5].y, border[5].z);
                    
                    glEnd();
                    
                    
                    
                    //Point cloud 
                    
                    glBegin(GL_POINTS);
                    
                    //kinects with same surface 
                    for(KinectInstance * pointKinect in instances){
                        if([pointKinect surface] == [kinect surface] && [pointKinect kinectConnected]){
                            xn::DepthMetaData dmd;
                            [pointKinect getDepthGenerator]->getXnDepthGenerator().GetMetaData(dmd);
                            
                            
                            int jump = (1-PropF(@"pointResolution")) * 10.0+1;
                            for(int y=0;y<480;y+=jump){
                                for(int x=0;x<640;x+=jump){
                                    XnPoint3D pIn;
                                    pIn.X = x;
                                    pIn.Y = y;
                                    pIn.Z = dmd.Data()[(int)pIn.X+(int)pIn.Y*640];
                                    XnPoint3D pOut;
                                    
                                    if(pIn.Z != 0){                               
                                        
                                        [pointKinect getDepthGenerator]->getXnDepthGenerator().ConvertProjectiveToRealWorld(1, &pIn, &pOut);
                                        ofVec3f p = [pointKinect convertWorldToSurface:ofVec3f(pOut.X, pOut.Y, pOut.Z)];;
                                        
                                        if(p.x >  0 && p.x < [kinect surfaceAspect] && p.y > 0 && p.y < 1 && p.z > 0){
                                            if(pointKinect != kinect){
                                                glColor4f(0.3,1.0,0.3,0.5);                                            
                                            } else {
                                                glColor4f(0.3,1.0,0.3,1.0);
                                            }
                                            
                                        } else {
                                            if(pointKinect != kinect){
                                                glColor4f(1.0,1.0,1.0,0.4);
                                            } else {
                                                glColor4f(0.5,0.5,1.0,1.0);
                                            }
                                        }
                                        
                                        glVertex3f(p.x,p.y,p.z);
                                    }
                                }
                            }
                        }
                    }
                    glEnd();
                    
                }glPopMatrix();
                
            }glPopMatrix();
            //    glDisable(GL_DEPTH);
            //  glDisable(GL_DEPTH_TEST);
            
            /*} else {
             //----------
             //Blob segment view	
             glPushMatrix();{
             glTranslated(0, 0, 0);
             
             int c = NUM_SEGMENTS/2.0;
             for(int i=0;i<c;i++){
             ofSetColor(200, 255, 200);
             grayImage[i]->draw(i*640/c,0,640/c,480/c);
             
             ofSetColor(255, 255, 255);
             ofLine(i*640/c, 0, i*640/c, 480/c);
             if(distanceNear[i] > 0)
             ofDrawBitmapString("Segment "+ofToString(i)+"\n "+ofToString(distanceNear[i])+" - "+ofToString(distanceFar[i]), i*640/c+5, 10);
             }
             glTranslated(0, 480/c, 0);
             for(int i=c;i<c*2;i++){
             ofSetColor(200, 255, 200);
             grayImage[i]->draw((i-c)*640/c,0,640/c,480/c);
             
             ofSetColor(255, 255, 255);
             ofLine((i-c)*640/c, 0, (i-c)*640/c, 480/c);
             if(distanceNear[i] > 0)
             ofDrawBitmapString("Segment "+ofToString(i)+"\n "+ofToString(distanceNear[i])+" - "+ofToString(distanceFar[i]), (i-c)*640/c+5, 10);
             
             }
             ofLine(0, 0, 640, 0);
             ofLine(0, 480/c, 640, 480/c);
             ofLine(0, 480/c*2, 640, 2*480/c);
             
             }glPopMatrix();	
             
             
             //----------
             //Heat view
             glPushMatrix();{
             glTranslated(0, 480-30, 0);
             glBegin(GL_LINES);
             for(int i=0;i<1000;i++){
             glColor3f(threadHeatMap[i]*20, threadHeatMap[i]*20, threadHeatMap[i]*20);
             glVertex3d(640.0*i/1000.0, 0, 0);
             glVertex3d(640.0*i/1000.0, 20, 0);
             }
             glEnd();
             
             glBegin(GL_LINES);
             for(int i=0;i<NUM_SEGMENTS;i++){
             if(distanceNear[i] > 0){
             switch (i) {
             case 0:
             ofSetColor(255, 0, 0);
             break;
             case 1:
             ofSetColor(0, 255, 0);
             break;
             case 2:
             ofSetColor(0, 0, 255);
             break;
             case 3:
             ofSetColor(255, 255, 0);
             break;
             case 4:
             ofSetColor(255, 0, 255);
             break;
             default:
             break;
             }
             
             //glColor3f(threadHeatMap[i]*20, threadHeatMap[i]*20, threadHeatMap[i]*20);
             glVertex3d(640.0*distanceNear[i]/10000, 0, 0);
             glVertex3d(640.0*distanceNear[i]/10000, 20, 0);
             glVertex3d(640.0*distanceFar[i]/10000, 0, 0);
             glVertex3d(640.0*distanceFar[i]/10000, 20, 0);
             
             }
             }
             glEnd();
             
             glBegin(GL_LINES);
             Blob * b;
             for(b in blobs){
             switch ([b segment]) {
             case 0:
             ofSetColor(255, 0, 0);
             break;
             case 1:
             ofSetColor(0, 255, 0);
             break;
             case 2:
             ofSetColor(0, 0, 255);
             break;
             case 3:
             ofSetColor(255, 255, 0);
             break;
             case 4:
             ofSetColor(255, 0, 255);
             break;
             default:
             break;
             }
             glVertex3d(640.0*[b avgDepth]/10000, 0, 0);
             glVertex3d(640.0*[b avgDepth]/10000, 30, 0);
             
             }
             glEnd();
             
             
             } glPopMatrix();
             
             
             //----------
             //Blob view
             glPushMatrix();{
             glTranslated(0, 480, 0);
             
             glPushMatrix();
             glScaled(0.5, 0.5, 1.0);
             users.draw();
             glPopMatrix();
             
             PersistentBlob * blob;				
             for(blob in persistentBlobs){
             int i=blob->pid%5;
             switch (i) {
             case 0:
             ofSetColor(255, 0, 0,255);
             break;
             case 1:
             ofSetColor(0, 255, 0,255);
             break;
             case 2:
             ofSetColor(0, 0, 255,255);
             break;
             case 3:
             ofSetColor(255, 255, 0,255);
             break;
             case 4:
             ofSetColor(0, 255, 255,255);
             break;
             case 5:
             ofSetColor(255, 0, 255,255);
             break;
             
             default:
             ofSetColor(255, 255, 255,255);
             break;
             }
             Blob * b;
             for(b in [blob blobs]){
             glBegin(GL_LINE_STRIP);
             for(int i=0;i<[b nPts];i++){
             ofVec2f p = [b pts][i];
             //				p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" surface:"Floor"];
             p = [b originalblob]->pts[i];
             glVertex2f(320*p.x, 240*p.y);
             
             //glVertex2f(w*3+p.x/640.0*w, p.y/480.0*h);
             //cout<<p.x<<"  "<<p.y<<endl;
             
             }
             glEnd();
             }
             }
             
             }glPopMatrix();	
             }*/
        }
    }
}


-(IBAction) resetCalibration:(id)sender{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Reset calibration?"];
    [alert setInformativeText:@"Cannot be restored!"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self reset];
    }
    [alert release];
    
}

-(void) reset{
    [[self getSelectedConfigureInstance] reset];
    
    /* [customProperties setValue:[NSNumber numberWithFloat:0.1] forKey:@"point0a"];
     [customProperties setValue:[NSNumber numberWithFloat:0.1] forKey:@"point0b"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point0x"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point0y"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point0z"];
     
     [customProperties setValue:[NSNumber numberWithFloat:0.9] forKey:@"point1a"];
     [customProperties setValue:[NSNumber numberWithFloat:0.1] forKey:@"point1b"];
     [customProperties setValue:[NSNumber numberWithInt:1] forKey:@"point1x"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point1y"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point1z"];
     
     [customProperties setValue:[NSNumber numberWithFloat:0.1] forKey:@"point2a"];
     [customProperties setValue:[NSNumber numberWithFloat:0.9] forKey:@"point2b"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point2x"];
     [customProperties setValue:[NSNumber numberWithInt:1] forKey:@"point2y"];
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"point2z"];		
     
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"proj0x"];
     [customProperties setValue:[NSNumber numberWithFloat:0.1] forKey:@"proj0y"];
     
     [customProperties setValue:[NSNumber numberWithFloat:[self surfaceAspect]] forKey:@"proj1x"];
     [customProperties setValue:[NSNumber numberWithFloat:0.1] forKey:@"proj1y"];
     
     [customProperties setValue:[NSNumber numberWithInt:0] forKey:@"proj2x"];
     [customProperties setValue:[NSNumber numberWithInt:1] forKey:@"proj2y"];
     [self calculateMatrix];*/
}


-(KinectInstance*) getInstance:(int)num{
    return [instances objectAtIndex:num];
}

-(KinectInstance*) getSelectedConfigureInstance{
    if([instanceSegmentedControl selectedSegment] == -1)
        return nil;
    return [self getInstance:[instanceSegmentedControl selectedSegment]];
}

-(ofxTrackedUser*) getDancer:(int)d{
    /* ofxTrackedUser* u = users.getUserWithId(dancers[d].userId);
     if(u != nil){
     return u;
     }
     return nil;	*/
}
/*
 -(IBAction) storeCalibration:(id)sender{
 int dancer;
 if(sender == storeA){
 dancer = 0;
 }
 if(sender == storeB){
 dancer = 1;
 }
 if(sender == storeC){
 dancer = 2;
 }
 
 vector<ofxTrackedUser*> vusers = users.getTrackedUsers(); 			
 for(int i=0;i<vusers.size();i++){
 bool matchingUser = NO;
 for(int j=0;j<3;j++){
 if(vusers[i]->id == dancers[j].userId){
 matchingUser = YES;
 }
 }
 if(!matchingUser){
 ofxTrackedUser * user = vusers[i];
 if(user->is_tracked){
 NSLog(@"Store calibration");
 XnStatus status = users.getXnUserGenerator().GetSkeletonCap().SaveCalibrationData(user->id,dancer);
 dancers[dancer].state = 2;
 dancers[dancer].userId = user->id;
 }
 break;	
 }
 }
 
 
 
 }*/

-(void)controlMouseScrolled:(NSEvent *)theEvent{
    if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 1){
        
        float deltaY = -[theEvent deltaY]*0.02;
        ofVec3f v = camCoord - eyeCoord;
        camCoord = eyeCoord + v + v.normalized()*deltaY;
    }
}


-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
    KinectInstance * instance = [self getSelectedConfigureInstance];
    if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 0){
        
        if(draggedPoint != -1){
            ofVec2f mouse = ofPoint(2*x/640.0,2*y/480.0);
            
            if(draggedPoint <= 3){
                if([instance calibration2d]){
                    mouse.x -= 1;
                    [instance setPoint2:draggedPoint coord:mouse];
                } else {
                    xn::DepthMetaData dmd;
                    [instance getDepthGenerator]->getXnDepthGenerator().GetMetaData(dmd);
                    
                    XnPoint3D pIn;
                    pIn.X = mouse.x*640;
                    pIn.Y = mouse.y*480;
                    pIn.Z = dmd.Data()[(int)pIn.X+(int)pIn.Y*640];
                    XnPoint3D pOut;
                    
                    if(pIn.Z != 0){
                        [instance getDepthGenerator]->getXnDepthGenerator().ConvertProjectiveToRealWorld(1, &pIn, &pOut);
                        ofVec3f coord = ofVec3f(pOut.X, pOut.Y, pOut.Z);
                        [instance setPoint3:draggedPoint coord:coord];
                        [instance setPoint2:draggedPoint coord:mouse];
                    }
                }
                
            } else {
                mouse.y -= 1;
                float aspect = [instance surfaceAspect];
                if(aspect < 1){
                    mouse.x -= 0.5;
                    mouse.x += aspect/2.0;
                } else {
                    mouse.y -= 0.5;
                    mouse.y += (1.0/aspect)/2.0;
                    mouse *= aspect;
                }
                
                mouse.x = ofClamp(mouse.x, 0, [instance surfaceAspect]);
                mouse.y = ofClamp(mouse.y, 0, 1);
                
                [instance setProjPoint:draggedPoint-4 coord:mouse];
                
                if(draggedPoint-4 <= 1){
                    ofVec2f v = [instance projPoint:1] - [instance projPoint:0];
                    v = ofVec2f(-v.y,v.x)*1.0/aspect;
                    
                    [instance setProjPoint:2 coord:[instance projPoint:0]+v];
                }
            }
        }
        [instance calculateMatrix];
    } else if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 1){
        ofVec3f v = camCoord - eyeCoord;
        v.rotate(-(x - mouseLastX)*0.2, ofVec3f(0,1,0));
        v.rotate((y - mouseLastY)*0.2, ofVec3f(-v.z,0,v.x));
        
        camCoord = eyeCoord + v;
        mouseLastX = x; mouseLastY = y;
    }
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
    KinectInstance * instance = [self getSelectedConfigureInstance];
    if([instance kinectConnected]){
        if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 0){
            
            ofVec2f mouse = ofPoint(2*x/640,2*y/480);
            draggedPoint = -1;
            if(mouse.y <= 1){
                if([instance calibration2d]){
                    mouse.x -= 1;
                    for(int i=0;i<4;i++){
                        if (mouse.distance([instance point2:i]) < 0.035) {
                            draggedPoint = i;
                        }
                    }
                } else {
                    for(int i=0;i<3;i++){
                        if (mouse.distance([instance point2:i]) < 0.035) {
                            draggedPoint = i;
                        }
                    }
                }
            } else {
                mouse.y -= 1;	
                float aspect = [instance surfaceAspect];
                if(aspect < 1){
                    mouse.x -= 0.5;
                    mouse.x += aspect/2.0;
                } else {
                    mouse.y -= 0.5;
                    mouse.y += (1.0/aspect)/2.0;
                    mouse *= aspect;
                }
                
                for(int i=0;i<2;i++){
                    if (mouse.distance([instance projPoint:i]) < 0.035) {
                        draggedPoint = i+4;
                    }
                }
            }
            xn::DepthMetaData dmd;
            [instance getDepthGenerator]->getXnDepthGenerator().GetMetaData(dmd);
            
            XnPoint3D pIn;
            pIn.X = mouse.x*640;
            pIn.Y = mouse.y*480;
            
            if(draggedPoint != -1){
                [NSCursor hide];
            }
            NSLog(@"Mouse pressed %i  mouse: %fx%f   depth at mouse: %i",draggedPoint, mouse.x, mouse.y,dmd.Data()[(int)pIn.X+(int)pIn.Y*640]);
        } else if([openglTabView indexOfTabViewItem:[openglTabView selectedTabViewItem]] == 1){
            mouseLastX = x; mouseLastY = y;
        }
    }
}

-(void) controlMouseReleased:(float)x y:(float)y{
    draggedPoint = -1;
    
    [NSCursor unhide];
}


-(void) applicationWillTerminate:(NSNotification *)note{
    for(KinectInstance * instance in instances){
        [instance setStop:YES];
        [instance getOpenNIContext]->getXnContext().Shutdown();
    }
}



@end
#endif