#pragma once

#import "Plugin.h"

@interface KeystoneProjector : NSObject {
	NSMutableArray * surfaces;
	int viewNumber;
	int projectorNumber;
}

@property (retain, readwrite) NSArray * surfaces;
@property (readwrite) int viewNumber;
@property (readwrite) int projectorNumber;

-(id) initWithSurfaces:(NSArray*)_surfaces viewNumber:(int)viewNumber projectorNumber: (int)projectorNumber;
-(NSString*) viewName;
-(void) applySurface:(NSString*)surfaceName;

@end
