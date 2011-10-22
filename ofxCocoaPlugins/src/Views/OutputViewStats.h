#pragma once

#include "GL/glew.h"

#include "ofMain.h"


#import <Cocoa/Cocoa.h>

@class PluginOpenGLView;
@interface OutputViewStats : NSView {
	NSNumber* fps;
//	GRChartView * graphView;
	
	NSMutableArray * historyData;
}
@property (retain) NSNumber* fps;

-(id) initWithFrame:(NSRect)frameRect outputView:(PluginOpenGLView*)view;
-(void)reloadGraph;
-(void) addHistory:(NSNumber*)fps;
@end
