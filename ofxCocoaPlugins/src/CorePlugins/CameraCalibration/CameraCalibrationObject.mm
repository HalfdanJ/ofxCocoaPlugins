
#import "CameraCalibrationObject.h"
#import "KeystoneSurface.h"
#import "Keystoner.h"

@implementation CameraCalibrationObject
@synthesize camera, surface, active, coordWarper, isCalibrated, lensStatus, cameraCalibrator;


-(id) initWithCamera:(Camera*)_camera surface:(KeystoneSurface*)_surface{
    self = [super init];
    if (self) {
        camera = _camera;
        surface = _surface;
        
        isCalibrated = NO;
        
        [self resetCamHandles];
        [self resetProjHandles];
        [self resetLensCalibration];
    }
    return self;
}

-(NSString*) surfaceName{
    return [surface name];
}
-(float) surfaceAspect{
    return [[surface aspect] floatValue];
}

//Proj handle
-(ofVec2f) projHandle:(int)i{
    return projHandles[i];
}
-(void) setProjHandle:(int)i to:(ofVec2f)p{
    projHandles[i] = p;
    [self calculateMatrix];
}


//Cam handle
-(ofVec2f) camHandle:(int)i{
    return camHandles[i];
}

-(void) setCamHandle:(int)i to:(ofVec2f)p{
    camHandles[i] = p;
    [self calculateMatrix];
}


//Reset
-(void) resetCamHandles{
    [self setCamHandle:0 to:ofVec2f(0.1,0.1)];
    [self setCamHandle:1 to:ofVec2f(0.9,0.1)];
    [self setCamHandle:2 to:ofVec2f(0.9,0.9)];
    [self setCamHandle:3 to:ofVec2f(0.1,0.9)];
}

-(void) resetProjHandles{
    [self setProjHandle:0 to:ofVec2f(0,0)];
    [self setProjHandle:1 to:ofVec2f([self surfaceAspect],0)];
    [self setProjHandle:2 to:ofVec2f([self surfaceAspect],1)];
    [self setProjHandle:3 to:ofVec2f(0,1)];
}

-(void) resetCamHandlesAsking{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Reset camera calibration?"];
    [alert setInformativeText:@"Cannot be restored!"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetCamHandles];
    }
    [alert release];
}

-(void) resetProjHandlesAsking{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Reset projector handles?"];
    [alert setInformativeText:@"Cannot be restored!"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetProjHandles];
    }
    [alert release];
}



-(void) calculateMatrix{ 
    //Create the coordinate warper
    if(coordWarper != nil){
        delete coordWarper;
    }
    coordWarper = new coordWarping();        
    ofVec2f src[4];
    ofVec2f dst[4];    
    
    src[0].x = [self projHandle:0].x;
    src[0].y = [self projHandle:0].y;
    src[1].x = [self projHandle:1].x;
    src[1].y = [self projHandle:1].y;
    src[2].x = [self projHandle:2].x;
    src[2].y = [self projHandle:2].y;
    src[3].x = [self projHandle:3].x;
    src[3].y = [self projHandle:3].y;    
    
    
    for(int i=0;i<4;i++){
        ofVec2f p = [self camHandle:i];
        dst[i].x = p.x ;
        dst[i].y = p.y ;
    }
    
    coordWarper->calculateMatrix(dst, src);
}

#pragma mark Lens calibration

-(void)resetLensCalibration{
    calibrationState = CALIBRATION_VIRGIN;
    [self setLensStatus:@"No calibration"];
    
    
}

-(void)addImageLensCalibration{
    addImage = YES;
    [self setLensStatus:@"Calculating..."];
}

-(void)calibrateLensCalibration{
    calibrationState = CALIBRATION_CALIBRATED;
    [self setLensStatus:@"Calibrating..."];
    
    cameraCalibrator->calibrate();
    cameraCalibrator->undistort();

    [self setLensStatus:@"Calibrated!"];
    [self setIsCalibrated:YES];
}

-(void)newFrame{
    originalImage = [camera cvImage];
    hasUndistortedImage = NO;
    
    if(addImage){
        addImage = NO;
        
        if(cameraCalibrator == nil){
            cameraCalibrator = new ofCvCameraCalibration();
            CvSize csize = cvSize( [camera width], [camera height] );
            cameraCalibrator->allocate(csize, 7,7);
        }
        //Add lens calib image
        calibrationState = CALIBRATION_ADDEDIMAGES;
        ofxCvGrayscaleImage * img = new ofxCvGrayscaleImage();
        img->allocate( [camera width], [camera height]);
                *img = *originalImage;       

       if(cameraCalibrator->addImage(img->getCvImage())){
            [self setLensStatus:[NSString stringWithFormat:@"Image %i captured",cameraCalibrator->colorImages.size()]];
		} else {
            [self setLensStatus:@"No checkboard found"];
        }

       // ofSleepMillis(4000);
        delete img;
        NSLog(@"%@",lensStatus);
        
    }
}

-(ofxCvGrayscaleImage*) getUndistortedImage{
    if(originalImage == nil){
        return nil;
    }
    if([self isCalibrated]){
		if (!hasUndistortedImage) {
            if(undistortedImage == nil){
                undistortedImage = new ofxCvGrayscaleImage();
                undistortedImage->allocate([camera width], [camera height]);
            }
            *undistortedImage = *originalImage;
		//	cvCvtColor( originalImage->getCvImage(), undistortedImage->getCvImage(), CV_RGB2GRAY );
			undistortedImage->flagImageChanged();
			undistortedImage->undistort( cameraCalibrator->distortionCoeffs[0], 
                                        cameraCalibrator->distortionCoeffs[1],
                                        cameraCalibrator->distortionCoeffs[2], 
                                        cameraCalibrator->distortionCoeffs[3],
                                        cameraCalibrator->camIntrinsics[0], 
                                        cameraCalibrator->camIntrinsics[4],
                                        cameraCalibrator->camIntrinsics[2], 
                                        cameraCalibrator->camIntrinsics[5] );   
			hasUndistortedImage = YES;
		}
        return undistortedImage;
	}
	return originalImage;
}

#pragma mark Conversion

-(ofVec2f) surfaceToCamera:(ofVec2f)p{
    return coordWarper->inversetransform (p.x,p.y);
}

-(ofVec2f) cameraToSurface:(ofVec2f)p{
    return coordWarper->transform (p.x,p.y);    
}

-(ofVec2f) surfaceCorner:(int)n{
    switch (n) {
        case 0:
            return [self surfaceToCamera:ofVec2f(0,0)];
            break;
        case 1:
            return [self surfaceToCamera:ofVec2f([self surfaceAspect],0)];
            break;
        case 2:
            return [self surfaceToCamera:ofVec2f([self surfaceAspect],1)];
            break;
        case 3:
            return [self surfaceToCamera:ofVec2f(0,1)];
            break;            
        default:
            return nil;
            break;
    }  
    
}
@end
