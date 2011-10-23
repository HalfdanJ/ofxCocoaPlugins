//
// PluginOpenglControlView is the view that can be embedded in a plugin nib file for opengl view in the interface. 
// The view has second priority after the main opengl view
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


