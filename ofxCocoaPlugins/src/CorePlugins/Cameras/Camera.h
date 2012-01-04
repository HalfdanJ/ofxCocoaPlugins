#pragma once

#import <ofxCocoaPlugins/Plugin.h>

@class CameraInstance;
@interface Camera : NSObject {
	NSDictionaryController * cameraTypesController;
	NSArrayController * cameraInstancesController;
	
	NSMutableDictionary * cameraInstancesRef;
	
	CameraInstance * cameraInstance;
	
	NSView * subview;
}

@property (retain) NSMutableDictionary * cameraInstancesRef;
@property (retain) CameraInstance * cameraInstance;

@property (retain) NSDictionaryController * cameraTypesController;

@property (retain) NSArrayController * cameraInstancesController;

-(id)initWithCameraInstances:(NSMutableDictionary*)dict;
-(NSView*) makeViewInRect:(NSRect)rect;

-(void) updateChosenCamera;

-(void)setup;
-(void)update;

-(BOOL) isFrameNew;

-(void) draw:(NSRect)rect;

@end
