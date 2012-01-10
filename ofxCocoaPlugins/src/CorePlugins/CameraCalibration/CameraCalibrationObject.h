#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/Cameras.h>

@interface CameraCalibrationObject : NSObject{
    Camera * camera;
    NSString * surface;
    BOOL active;
}

@property (readonly) Camera * camera;
@property (readonly) NSString * surface;
@property (readwrite) BOOL active;

-(id) initWithCamera:(Camera*)camera surface:(NSString*)surface;

@end
