#pragma once


#define Surface(s,p) ([GetPlugin(Keystoner) getSurface:s viewNumber:ViewNumber projectorNumber:p])

#define Aspect(s,p) ([[Surface(s,p) aspect] floatValue])

//#define ApplySurface(s,p) if([Surface(s,p) visible]) { [Surface(s,p) apply];
#define ApplySurfaceForProjector(s,p) {if([Surface(s,p) visible]) { [GetPlugin(Keystoner)  applySurface:s projectorNumber:p viewNumber:ViewNumber];
#define PopSurfaceForProjector() [GetPlugin(Keystoner)  popSurface]; }}

#define ApplySurface(s) {int appliedProjector=-1;for(KeystoneProjector*proj in [[[GetPlugin(Keystoner) outputViews] objectAtIndex:ViewNumber] projectors]){ appliedProjector++; if(appliedProjector > 0)[GetPlugin(Keystoner)  popSurface]; ApplySurfaceForProjector(s,appliedProjector)

#define PopSurface() PopSurfaceForProjector() }}}

/*
{int appliedProjector=-1;for(KeystoneProjector*proj in [[[GetPlugin(Keystoner) outputViews] objectAtIndex:ViewNumber] projectors]){ appliedProjector++; if(appliedProjector > 0)[GetPlugin(Keystoner)  popSurface]; {if([Surface(s,p) visible]) { [GetPlugin(Keystoner)  applySurface:s projectorNumber:p viewNumber:ViewNumber];
	[GetPlugin(Keystoner)  popSurface]; } }}}
*/
#include "Plugin.h"

#include "KeystonerOutputview.h"
#include "TrackingLayer.h"
#import "KeystoneSurface.h"


//{int appliedProjector=-1;for(KeystoneProjector*proj in [[[GetPlugin(Keystoner) outputViews] objectAtIndex:ViewNumber] projectors]){ appliedProjector++; if(appliedProjector > 0)[GetPlugin(Keystoner)  popSurface]; {if([Surface(s,p) visible]) { [GetPlugin(Keystoner)  applySurface:s projectorNumber:p viewNumber:ViewNumber];
//    
//    
//    [GetPlugin(Keystoner)  popSurface]; } }}


@interface Keystoner : ofPlugin {
	IBOutlet NSSegmentedControl * outputViewPicker;
	IBOutlet NSSegmentedControl * projectorPicker;
	IBOutlet NSSegmentedControl * surfacePicker;
	
	IBOutlet NSView * trackingArea;
	
	IBOutlet NSArrayController * outputViewController;
	IBOutlet NSArrayController * projectorArrayController;
	IBOutlet NSArrayController * surfaceArrayController;
	
	IBOutlet NSSegmentedControl * drawSettings;
	
	IBOutlet NSButton * projectionPlusButton;
	IBOutlet NSButton * projectionMinusButton;

	TrackingLayer * trackingLayer;
	
	NSMutableArray * outputViews;
	NSArray * surfaces;
	int selectedOutputview;
	int selectedProjector;
	int selectedSurface;
	
	ofTrueTypeFont * font;
	ofImage * recoilLogo;	
	
	KeystoneSurface * appliedSurface;
	
	BOOL willDraw;
	
	ofImage * gammaFade;
	
	int controlWidth;
	int controlHeight;
	
	int selectedSurfaceCorner;
	int hoveredSurfaceCorner;
	float zoomLevel;
}

-(IBAction) addProjector:(id)sender;
-(IBAction) removeProjector:(id)sender;
-(IBAction) setViewMode:(id)sender;


-(void) updateProjectorButtons;
-(id) initWithSurfaces:(NSArray*)surfaces;
-(void) setCornerArray:(NSMutableArray*)array;
-(KeystoneSurface*) getSurface:(NSString*)name viewNumber:(int)number projectorNumber:(int)projectorNumber;
-(KeystoneSurface*) getSurface:(NSString*)name viewName:(NSString*)viewName projectorNumber:(int)projectorNumber;
-(void) setup;

-(void) applySurface:(NSString*)surfaceName projectorNumber:(int)projectorNumber viewNumber:(int)viewNumber;
-(void) applySurface:(KeystoneSurface*)surface;

-(void) popSurface;
@property (retain, readonly) TrackingLayer * trackingLayer;

@property (retain, readonly) NSMutableArray * outputViews;
@property (retain, readwrite) NSIndexSet * selectedOutputviewIndexSet;
@property (readwrite) int selectedOutputview;

@property (retain, readwrite) NSIndexSet * selectedProjectorIndexSet;
@property (readwrite) int selectedProjector;

@property (retain, readwrite) NSIndexSet * selectedSurfaceIndexSet;
@property (readwrite) int selectedSurface;
@property (retain, readonly) NSArray * surfaces;

@property (readonly) ofTrueTypeFont * font;
@property (readonly) ofImage * recoilLogo;


@end
