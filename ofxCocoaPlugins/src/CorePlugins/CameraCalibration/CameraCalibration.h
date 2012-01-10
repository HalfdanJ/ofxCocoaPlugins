#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/Cameras.h>

@class CameraCalibrationObject;
@interface CameraCalibration : ofPlugin {
    int controlWidth;
    int controlHeight;
    
    NSArrayController * camerasArrayController;
    NSArrayController * surfacesArrayController;
    
    NSMutableDictionary * calibrationObjects;
    CameraCalibrationObject * selectedCalibrationObject;
    
    BOOL changingSurface;
}

@property (readonly) NSArrayController * camerasArrayController;
@property (readonly) NSArrayController * surfacesArrayController;
@property (readonly) CameraCalibrationObject * selectedCalibrationObject;
@property (readwrite) BOOL changingSurface;

-(CameraCalibrationObject *) calibrationForCamera:(Camera*)camera surface:(NSString*)surface;
@end
