#pragma once




#import "GLee.h"
#include "ofMain.h"


#import <Cocoa/Cocoa.h>
#import "GRChartView.h"
#import "GRPieDataSet.h"
#import "GRXYDataSet.h"
#import "GRAreaDataSet.h"
#import "GRLineDataSet.h"
#import "GRColumnDataSet.h"
#import "GRAxes.h"

@class PluginOpenGLView;
@interface OutputViewStats : NSView {
	NSNumber* fps;
	GRChartView * graphView;
	
	NSMutableArray * historyData;
}
@property (retain) NSNumber* fps;

-(id) initWithFrame:(NSRect)frameRect outputView:(PluginOpenGLView*)view;
-(void)reloadGraph;
-(void) addHistory:(NSNumber*)fps;
@end
