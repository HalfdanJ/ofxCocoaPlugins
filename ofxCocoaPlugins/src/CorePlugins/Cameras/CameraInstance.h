#pragma once

#include "Plugin.h"
#include "ofxCvMain.h"

@interface CameraInstance : NSObject {
	BOOL camInited;
	BOOL camIsIniting;
	BOOL camIsClosing;
    BOOL camIsConnected;
    int referenceCount;
	
	NSString * name;
	NSString * status;
	
	BOOL bIsFrameNew;
	unsigned char* pixels;
	int width, height;
	float mytimeNow, mytimeThen;
	int myframes;
	float myfps,frameRate;
	ofTexture * tex;
    long long frameNum;
	
	NSMutableDictionary * cameraInstances;

	BOOL enabled;
    
    ofxCvGrayscaleImage * cvImage;
    long long cvFrameNum;
}
@property (readwrite) BOOL enabled;
@property (retain) NSString * name;
@property (retain) NSString * status;
@property (readwrite) ofTexture * tex;
@property (readwrite) unsigned char* pixels;
@property (retain) 	NSMutableDictionary * cameraInstances;
@property (readonly) int width;
@property (readonly) int height;

@property (readwrite) BOOL camInited;
@property (readwrite) BOOL camIsIniting;
@property (readwrite) BOOL camIsClosing;
@property (readwrite) BOOL camIsConnected;
@property (readwrite) int referenceCount;
@property (readonly) long long frameNum;

//Connect to the camera, and start streaming
-(void) initCam;

//Close the connection to the camera (make sure you can connect again)
-(void) close;

- (void)update;
- (void)videoGrabberInit;
-(NSView*) makeViewInRect:(NSRect)rect;
-(void) drawCamera:(NSRect)rect;
-(void) loadSettingsDict:(NSMutableDictionary*)dict;
-(void) addPropertiesToSave:(NSMutableDictionary*)dict;
-(ofxCvGrayscaleImage*) cvImage;

//Aspect of the image
-(float) aspect;
@end
