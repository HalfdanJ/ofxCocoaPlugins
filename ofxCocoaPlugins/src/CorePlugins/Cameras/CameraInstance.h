#pragma once

#include "Plugin.h"

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
	
	NSMutableDictionary * cameraInstances;

	BOOL enabled;
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
@end
