#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/Cameras.h>
#import <ofxCocoaPlugins/coordWarp.h>
#import <ofxCocoaPlugins/ofCvCameraCalibration.h>
#import "ofxCvMain.h"

enum calibrationStates {
    CALIBRATION_VIRGIN,
    CALIBRATION_ADDEDIMAGES,
    CALIBRATION_CALIBRATED
};

@class KeystoneSurface;
@interface CameraCalibrationObject : NSObject{
    Camera * camera;
    KeystoneSurface * surface;
    BOOL active;
    
    ofVec2f projHandles[4];
    ofVec2f camHandles[4];
    
    coordWarping * coordWarper;
    
    //Lens calibration
    BOOL isCalibrated;
    BOOL hasUndistortedImage;
    ofCvCameraCalibration * cameraCalibrator;
    calibrationStates calibrationState;
    BOOL addImage;
    ofxCvGrayscaleImage * undistortedImage;
    ofxCvGrayscaleImage * originalImage;
    
    NSString * lensStatus;
    
}

@property (readonly) Camera * camera;
@property (readonly) KeystoneSurface * surface;
@property (readwrite) BOOL active;
@property (readonly) coordWarping * coordWarper;

@property (readwrite) BOOL isCalibrated;
@property (retain, readwrite) NSString * lensStatus;
@property (readwrite) ofCvCameraCalibration * cameraCalibrator;

-(id) initWithCamera:(Camera*)camera surface:(KeystoneSurface*)surface;

-(NSString*) surfaceName;
-(float) surfaceAspect;

-(ofVec2f) projHandle:(int)i;
-(void) setProjHandle:(int)i to:(ofVec2f)p;

-(ofVec2f) camHandle:(int)i;
-(void) setCamHandle:(int)i to:(ofVec2f)p;

-(void) resetCamHandles;
-(void) resetProjHandles;

-(void) resetCamHandlesAsking;
-(void) resetProjHandlesAsking;

-(void) calculateMatrix;
-(ofVec2f) surfaceToCamera:(ofVec2f)p;
-(ofVec2f) cameraToSurface:(ofVec2f)p;
-(ofVec2f) surfaceCorner:(int)n;

-(void) resetLensCalibration;
-(void) addImageLensCalibration;
-(void) calibrateLensCalibration;
-(ofxCvGrayscaleImage*) getUndistortedImage;

-(void) newFrame;

@end

