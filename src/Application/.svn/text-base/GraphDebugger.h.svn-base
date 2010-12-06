//
//  graphDebugger.h
//  simpleExample
//
//  Created by Jonas Jongejan on 09/03/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//
#pragma once

#include "GLee.h"

#import <Cocoa/Cocoa.h>
#include "PluginProperty.h"
#import "GRChartView.h"
#import "GRPieDataSet.h"
#import "GRXYDataSet.h"
#import "GRAreaDataSet.h"
#import "GRLineDataSet.h"
#import "GRColumnDataSet.h"
#import "GRAxes.h"


@class PluginManagerController;
extern PluginManagerController * globalController;
@interface GraphDebugger :  NSObject {
	IBOutlet NSView * hostView;
	IBOutlet GRChartView * graphView;
	NSMutableArray * scatterPlots;
	NSDate * startDate;
	
	
	
	NSMutableArray * properties;
	
	NSMutableArray * data;
	NSMutableArray * displayedData;
	NSMutableArray * newData;
	
	NSMutableDictionary * lastRefreshProperties;
	NSMutableDictionary * newRefreshProperties;
	
	NSTimer * refreshTimer;
	int lastRefresh;
	float changeRefreshrateTo;
	

}
/*
@property (retain, readonly) NSNumber * yMin;
@property (retain, readonly) NSNumber * yMax;
@property (retain, readwrite) NSNumber * yRangeMin;
@property (retain, readwrite) NSNumber * yRangeMax;
*/

@property (retain, readonly) NSNumber * xMin;
@property (retain, readonly) NSNumber * xMax;
@property (retain, readwrite) NSNumber * xRangeMin;
@property (retain, readwrite) NSNumber * xRangeMax;
@property (readonly,retain) NSMutableArray * displayedData;

@property (readonly, retain) NSMutableArray * properties;

-(void) addProperty:(PluginProperty*)property;
-(void) removeProperty:(PluginProperty*)property;

	
-(void) willChangeData;
-(void) didChangeData;
-(IBAction) setRefreshRate:(id)sender;
-(IBAction) reset:(id)sender;
@end
