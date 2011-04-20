#pragma once

#include "Plugin.h"

@interface CameraInstance : NSObject {
	BOOL camInited;
	BOOL camIsIniting;
	BOOL camWasInited;
	BOOL isClosing;
	
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

- (void)update;
- (void)videoGrabberInit;
-(NSView*) makeViewInRect:(NSRect)rect;
-(void) close;
-(void) drawCamera:(NSRect)rect;
-(void) loadSettingsDict:(NSMutableDictionary*)dict;
-(void) addPropertiesToSave:(NSMutableDictionary*)dict;
@end
