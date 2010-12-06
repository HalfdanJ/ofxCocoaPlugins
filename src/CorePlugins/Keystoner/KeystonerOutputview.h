#pragma once

#include "Plugin.h"
#import "PluginManagerController.h"
#import "PluginOpenGLView.h"
#import "KeystoneProjector.h"

@interface KeystonerOutputview : NSObject {
	int viewNumber;
	NSSize size;
	NSString * sizeRep;
	NSMutableArray * projectors;
	float aspect;
	NSString * name;
}

@property (readwrite) int viewNumber;
@property (readwrite) NSSize size;
@property (retain, readwrite) NSString * name;
@property (retain, readwrite) NSString * sizeRep;
@property (retain, readwrite) NSMutableArray * projectors;
@property (readwrite) float aspect;

-(id) initWithSurfaces:(NSArray*)surfaces;

-(void) applySurface:(NSString*)surfaceName projectorNumber:(int)projectorNumber;
@end
