//#import "ofConstants.h"

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@class OutputViewStats;
@class PluginManagerController;
@class OutputViewManager;

@interface PluginOpenGLView : NSOpenGLView {
	PluginManagerController * controller;
	OutputViewManager * viewManager;
    
	int viewNumber;
	
	double	deltaTime;
	double framesPerSecond;
    
	int	viewWidth;
	int	viewHeight;
    
	CVDisplayLinkRef displayLink; //display link for managing rendering thread
	CGDirectDisplayID    viewDisplayID;
    
	NSMutableDictionary * drawingInformation;
	
	BOOL fullscreen;
	BOOL inFullscreen;
	CFDictionaryRef originalMode;	
	
	CGDirectDisplayID displayId;
	
	OutputViewStats * statsView;
    
	NSSize screenSize;
	
	float avgTime;
	float maxTime;
	float minTine;
	
	int backingWidth, backingHeight;
}

@property (assign, readonly) int viewWidth;
@property (assign, readonly) int viewHeight;
@property (readwrite) int viewNumber;
@property (retain) PluginManagerController * controller;
@property (retain) OutputViewManager * viewManager;
@property (readwrite) CGDirectDisplayID displayId;
@property (retain) NSMutableDictionary * drawingInformation;
@property (readwrite) NSSize screenSize;
@property BOOL inFullscreen;

-(CVReturn)getFrameForTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;
-(void) updateDisplayIDWithWindow:(NSWindow*)window;

-(void) setDisplayNumber:(id)sender;

-(void) setBackingWidth:(int) width height:(int)height;
-(void)updateStats;

@end

