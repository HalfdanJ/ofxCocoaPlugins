//
//  NumberProperty.h
//  loadnloop
//
//  Created by LoadNLoop on 24/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#include "GLee.h"

#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/ScriptingBridge.h>

#include "PluginProperty.h"

#include "PluginManagerController.h"

@class PluginManagerController;
extern PluginManagerController * globalController;


@interface NumberProperty : PluginProperty {
	NSNumber * minValue;
	NSNumber * maxValue;
	
	float midiSmoothing;
	float midiGoal;
	bool valueSetFromMidi;
	NSDate * thisMidiTime;
	NSDate * lastMidiTime;

}
@property (retain) NSNumber * minValue;
@property (retain) NSNumber * maxValue;
@property (readwrite) float midiSmoothing; //closer to 1 is more smoothing (eg. 0.99)

+(NumberProperty*)sliderPropertyWithDefaultvalue:(float)defaultValue minValue:(float)min maxValue:(float)max;

-(void) setFloatValue:(float)v;
-(void) setIntValue:(int)v;
-(void) setBoolValue:(BOOL)v;
-(void) setDoubleValue:(double)v;
-(float)floatValue;
-(double)doubleValue;
-(int) intValue;
-(BOOL) boolValue;

-(void) clearSmoothing;

@end
