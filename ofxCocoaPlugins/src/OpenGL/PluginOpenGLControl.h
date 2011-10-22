//
//  PluginOpenGLLayer.h
//
//  Created by Jonas Jongejan on 19/11/09.
//

#pragma once 

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class PluginManagerController;
@class ofPlugin;

extern PluginManagerController * globalController;

@interface PluginOpenGLControlView : NSOpenGLView {	
	PluginManagerController * controller;

	NSMutableDictionary * drawingInformation;
    ofPlugin * plugin;
	int backingWidth, backingHeight;
    
    CVDisplayLinkRef displayLink; //display link for managing rendering thread
	CGDirectDisplayID    viewDisplayID;

}

@property (retain) PluginManagerController * controller;
@property (retain) NSMutableDictionary * drawingInformation;
@property (retain) ofPlugin * plugin;

- (CVReturn)getFrameForTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;

@end


@interface PluginOpenGLControl : NSOpenGLView {
	NSMutableDictionary * drawingInformation;
    ofPlugin * plugin;

}
@property (assign, readwrite) ofPlugin * plugin;


-(void) draw;

@end
