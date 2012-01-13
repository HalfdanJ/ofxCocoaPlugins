#pragma once

#import "Plugin.h"
#include "coordWarp.h"
#include "Warp.h"

@interface KeystoneSurface : NSObject {
	NSString * name;
	NSNumber * aspect;
	BOOL visible;
	float minAspectValue;
	float maxAspectValue;
	
	NSMutableArray * cornerPositions;
	
	Warp * warp;
	coordWarping * coordWarp;
	int viewNumber;
	int projectorNumber;
	
	int softedgePart;
	int softedgeTotalParts;
    
    float handleOffset;
}

@property (retain) NSString * name;
@property (retain) NSNumber * aspect;
@property (readwrite) BOOL visible;
@property (readwrite) float minAspectValue;
@property (readwrite) float maxAspectValue;
@property (retain) NSMutableArray * cornerPositions;
@property (readwrite) int viewNumber;
@property (readwrite) int projectorNumber;
@property (readwrite) int softedgePart;
@property (readwrite) int softedgeTotalParts;
@property (readwrite) float handleOffset;
@property (readonly) Warp * warp;

-(void) resetCorners;
-(void) recalculate;
-(void) drawGrid;
-(void) drawGridSimple:(BOOL)simple;
-(void) apply;
-(void) applyWithWidth:(float)width height:(float)height;
-(ofVec2f) convertToProjection:(ofVec2f)p;
-(ofVec2f) convertFromProjection:(ofVec2f)p;
-(void) setHandleOffsetWithoutRecalculation:(float)_offset;
-(IBAction) flipX;
-(IBAction) flipY;

@end
