#pragma once

#include "Plugin.h"
#include "IIDCCameraInstance.h"
#include "NormalCameraInstance.h"

@interface Camera : NSObject {
	NSDictionaryController * cameraTypesController;
	NSArrayController * cameraInstancesController;
	
	NSMutableDictionary * cameraInstancesRef;
	
	NSMutableDictionary * cameraInstance;
	
	NSView * subview;
	
	
	
	

}

@property (retain) NSMutableDictionary * cameraInstancesRef;
@property (retain) NSMutableDictionary * cameraInstance;

@property (retain) NSDictionaryController * cameraTypesController;

@property (retain) NSArrayController * cameraInstancesController;

-(id)initWithCameraInstances:(NSMutableDictionary*)dict;
-(NSView*) makeViewInRect:(NSRect)rect;

-(void) updateChoosedCamera;

-(void)setup;
-(void)update;

-(BOOL) isFrameNew;

-(void) draw:(NSRect)rect;

@end
