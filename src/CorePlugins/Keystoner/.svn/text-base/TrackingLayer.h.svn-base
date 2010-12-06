#include "Plugin.h"
#pragma once
@interface TrackingLayer : CALayer {
	CALayer * contentLayer;
	CALayer * outputViewLayer;
	
	NSMutableArray * constraintsArray;
	NSMutableArray * handles;
	NSMutableArray * handlePositionHolder;
	
	id dataTarget;
	
	float scale;
	float aspect;
	BOOL visible;
	
	int dragCorner;
	CGPoint lastMousePos;
}
@property (readonly) int dragCorner;
@property (assign) id dataTarget;
@property (readwrite) float scale;
@property (readwrite) float aspect;
@property (readwrite) BOOL visible;
@property (retain) 	NSMutableArray * handlePositionHolder;

-(void)setScale:(float)scale;
-(void) setup;
-(void) scrollWheel:(NSEvent *)theEvent;
@end
