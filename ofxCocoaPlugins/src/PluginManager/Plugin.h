#pragma once
#include "ofMain.h"

#import <Cocoa/Cocoa.h>

#define Prop(p) [properties objectForKey:(p)] 
#define PropF(p) [Prop( (p) ) floatValue]
#define PropB(p) [Prop( (p) ) boolValue]
#define PropI(p) [Prop( (p) ) intValue]

#define ViewNumber [[drawingInformation valueForKey:@"outputViewNumber"] intValue]
#define GetPlugin(p) ((p*)[globalController getPlugin:[p class]])
//#define tracker(t) (TrackerObject*)[GetPlugin(Tracking) trackerNumber:t]
//#define Surf(p,s) ((ProjectionSurfacesObject*)[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:p surface:s])
//#define ApplySurface(p,s) ([GetPlugin(ProjectionSurfaces) apply:p surface:s])

//#include "PluginProperty.h"

#include "NumberProperty.h"
#include "BoolProperty.h"

@class PluginManagerController, PluginOpenGLControlView;

extern PluginManagerController * globalController;

@interface ofPlugin : NSObject 
{
    IBOutlet NSView * view;
	IBOutlet PluginOpenGLControlView * controlGlView;

	NSString * name;
	NSNumber * enabled;
    NSImage * icon; //Not in use

	BOOL initPluginCalled;
	BOOL setupCalled;

	NSOpenGLView *controlLayer;

	int updateCpuTime;
	int drawCpuTime;
	
	NSArray * children;
	NSNumber * canDisable;
	
	NSMutableDictionary * properties;
	NSMutableDictionary * powerMeterDictionary;
	NSMutableDictionary * customProperties;

	float controlMouseX;
	float controlMouseY;
	int controlMouseFlags;
	
	NSNumber * midiChannel;	
}

@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSNumber *enabled;
@property (assign, readwrite) PluginOpenGLControlView * controlGlView;
//@property (readwrite) CAOpenGLLayer *controlLayer;

@property (assign, readwrite) NSView * view;
@property (readwrite) float updateCpuUsage;
@property (readwrite) float drawCpuUsage;
@property (readwrite) int updateCpuTime;
@property (readwrite) int drawCpuTime;
@property (readwrite) BOOL initPluginCalled;
@property (readwrite) BOOL setupCalled;
@property (retain) 	NSMutableDictionary * properties;
@property (retain) 	NSMutableDictionary * customProperties;
@property (retain) 	NSMutableDictionary * powerMeterDictionary;
@property (retain) NSImage * icon;
@property (readwrite) float controlMouseX;
@property (readwrite) float controlMouseY;
@property (readwrite) int controlMouseFlags;
@property (retain, readwrite) NSNumber * midiChannel;

- (void) initPlugin; //The function which the different plugin can put their init code in
- (BOOL) loadPluginNibFile;
- (void) setup;
- (void) draw:(NSDictionary*)drawingInformation;
- (void) update:(NSDictionary*)drawingInformation;

- (void) customPropertiesLoaded;
- (void) willSave;

- (void) controlDraw:(NSDictionary*)drawingInformation;

- (void) controlMouseMoved:(float) x y:(float)y;
- (void) controlMousePressed:(float) x y:(float)y button:(int)button;
- (void) controlMouseReleased:(float) x y:(float)y;
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button;
- (void) controlMouseScrolled:(NSEvent *)theEvent;
- (void) controlKeyPressed:(int)key modifier:(int)modifier;
- (void) controlKeyReleased:(int)key modifier:(int)modifier;
- (void) setBoolEnabled:(BOOL)b;
- (BOOL) boolEnabled;

- (BOOL) isEnabled;
- (BOOL) autoresizeControlview;
- (BOOL) willDraw:(NSMutableDictionary*)drawingInformation;

- (void) addProperty:(PluginProperty*)p named:(NSString*)name;
- (void) assignMidiChannel:(int) channel;

- (IBAction) qlabAll:(id)sender;
- (IBAction) generateMidiNumbers:(id)sender;

- (void) applicationWillTerminate: (NSNotification *)note;

@end

