#pragma once

#import <Cocoa/Cocoa.h>

@class PluginOpenGLView;
@class PluginManagerController;
@class PluginOutputWindowDelegate;

@interface OutputViewManager : NSObject {
	IBOutlet PluginManagerController * controller;
	IBOutlet NSToolbarItem * toolbarFullscreenItem;
	
	NSMutableArray * glViews;
	NSMutableArray * outputViewsPanels;
	int numberOutputViews;
	
	BOOL setupScreensCalled;
	BOOL fullscreen;
	
	//Ensures the aspect of the window
	PluginOutputWindowDelegate * theDelegate;
		
}
@property (readwrite) int numberOutputViews;
@property (readonly) NSMutableArray * glViews;


-(IBAction) goFullscreen;
-(IBAction) goWindow;
-(IBAction) pressFullscreenButton:(id)sender;

-(void) showViews;

-(void) setupScreen;
-(void) refreshScreens;

-(CGDisplayCount) getDisplayList:(CGDirectDisplayID **)displays;
@end

@interface PluginOutputWindowDelegate : NSObject < NSWindowDelegate >
{
	PluginOpenGLView * pov;
}

- (id) initWithPluginOutputView:(PluginOpenGLView*)thePOV;
- (NSSize)windowWillResize:(NSWindow *)window toSize: (NSSize)proposedFrameSize;
@end
