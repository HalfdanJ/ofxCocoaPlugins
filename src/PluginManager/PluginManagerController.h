#pragma once
#import "GLee.h"

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#include "testApp.h"
#include "PluginOpenGLView.h"
#include "MainWindow.h"
#include "SaveManager.h"
#include "OutputViewManager.h"

#include "ofxOsc.h"

@class ofPlugin;
@class TestAppController;

@interface PluginManagerController : NSObject <NSCoding, NSWindowDelegate>{
	IBOutlet TestAppController * testApp;
//	IBOutlet NSView * outputView;
	IBOutlet MainWindow * mainWindow;
	IBOutlet NSView * pluginControllerView;
	IBOutlet NSView * pluginPropertiesView;
	IBOutlet NSView * statsAreaView;
	IBOutlet NSBox * pluginTitleView;
	
	IBOutlet NSSplitView * pluginSplitView;

	IBOutlet NSOutlineView * pluginsOutlineView;

	IBOutlet NSTreeController * pluginsTreeController;	
	IBOutlet NSDictionaryController * pluginPropertiesController;

	IBOutlet NSTableColumn * pluginMeterColumn;
	IBOutlet NSTableColumn * propertiesValueColumn;
	IBOutlet NSTableColumn * propertiesControlColumn;
	IBOutlet NSPanel * graphPanel;
	IBOutlet NSToolbar * toolbar;
	IBOutlet NSToolbarItem * toolbarGraphItem;
	
	IBOutlet SaveManager * saveManager;
	IBOutlet OutputViewManager * viewManager;
	
	//Properties variables
	NSSliderCell * sliderCell;
	NSButtonCell * boolButtonCell;
	NSTextFieldCell * textfieldCell;

	//Plugins
	NSMutableArray * plugins;	
	NSTreeController * pluginTree;
	NSView * currentView;
	
	//States
	BOOL setupCalled;
	BOOL pluginsInited;
	BOOL setupAppCalled;
	BOOL previews;
	int lastPowerMeterUpdate;
	
	//Opengl
	NSRecursiveLock * openglLock;
	NSOpenGLContext * sharedOpenglContext;
	CFTimeInterval lastTime;	
	long startFrameTime;		
	float fps;
	
	ofxOscReceiver * oscReceiver;

	//Application delegation
	
	BOOL noQuestionsAsked;
	BOOL isQuitting;

}	

@property (retain) SaveManager * saveManager;
@property (retain) NSView * statsAreaView;
@property (assign, readwrite) NSOpenGLContext * sharedOpenglContext;
@property (assign) NSRecursiveLock * openglLock;
@property (readonly) float fps;
@property (assign) NSMutableArray * plugins;
@property (retain, readonly) OutputViewManager * viewManager;
@property (readwrite) BOOL noQuestionsAsked;

// @property (retain ) NSMutableArray *currentProperties;

//-(IBAction) setPropertyValue:(id)sender;
-(IBAction) toggleGraphView:(id)sender;
-(IBAction) showGraphView:(id)sender;
-(IBAction) hideGraphView:(id)sender;
-(IBAction) pressGraphViewButton:(id)sender;
-(IBAction)changePlugin:(id)sender;

- (void) initPlugins;
- (id) init;

- (void)addHeader:(NSString *)header;
- (void)addPlugin:(ofPlugin *)obj;
- (ofPlugin*) getPlugin:(Class)pluginClass;
- (ofPlugin*) selectedPlugin;

	
- (void) callSetup;
- (void) callDraw:(NSMutableDictionary*)drawingInformation;
- (BOOL) willDraw:(NSMutableDictionary*)drawingInformation;
- (BOOL) isSetupCalled;
- (BOOL) isPluginsInited;
- (int) countOfPlugins;

- (NSOpenGLContext*) getSharedContext:(CGLPixelFormatObj)pixelFormat;

-(void) mouseUpPoint:(NSPoint)theEvent;
-(void) mouseDownPoint:(NSPoint)theEvent;
-(void) mouseDraggedPoint:(NSPoint)theEvent;

-(void)setNumberOutputViews:(int)n;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app;
- (BOOL)windowShouldClose:(NSWindow *)sender;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)askToQuit:(NSWindow *) theWindow;

@end


