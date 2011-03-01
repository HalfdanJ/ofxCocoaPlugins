//
//  NumberProperty.h
//  loadnloop
//
//  Created by LoadNLoop on 24/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#include "GLee.h"

#import <Cocoa/Cocoa.h>
#include "PluginProperty.h"

@interface NumberProperty : PluginProperty {
	NSNumber * minValue;
	NSNumber * maxValue;

}
@property (retain) NSNumber * minValue;
@property (retain) NSNumber * maxValue;


+(NumberProperty*)sliderPropertyWithDefaultvalue:(float)defaultValue minValue:(float)min maxValue:(float)max;

-(void) setFloatValue:(float)v;
-(void) setIntValue:(int)v;
-(void) setBoolValue:(BOOL)v;
-(void) setDoubleValue:(double)v;
-(float)floatValue;
-(double)doubleValue;
-(int) intValue;
-(BOOL) boolValue;

@end
