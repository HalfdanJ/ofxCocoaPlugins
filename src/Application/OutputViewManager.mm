//
//  OutputViewManager.m
//  simpleExample
//
//  Created by LoadNLoop on 19/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OutputViewManager.h"
#include "PluginOpenGLView.h"
#include "PluginManagerController.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/graphics/IOFramebufferShared.h>
#include <IOKit/graphics/IOGraphicsInterface.h>
#include <IOKit/graphics/IOGraphicsLib.h>
#include <IOKit/graphics/IOGraphicsTypes.h>


static void KeyArrayCallback(const void *key, const void *value, void
							 *context) { CFArrayAppendValue((CFMutableArrayRef)context, key);  }

//Code to get the names of the displays
CFStringRef CopyLocalDisplayName(CGDirectDisplayID display)
{
    CFArrayRef          langKeys, orderLangKeys;
    CFStringRef        langKey, localName;
    io_connect_t displayPort;
    CFDictionaryRef dict, names;
	
    localName = NULL;
    displayPort = CGDisplayIOServicePort(display);
    if ( displayPort == MACH_PORT_NULL )
        return NULL;  /* No physical device to get a name from */
    dict = IOCreateDisplayInfoDictionary(displayPort, 0);
	//NSDictionary *deviceFullDescription = (NSDictionary *) IODisplayCreateInfoDictionary(displayPort, kNilOptions);
    names = (CFDictionaryRef) CFDictionaryGetValue( dict, CFSTR(kDisplayProductName) );
	
    /* Extract all the  display name locale keys */
    langKeys = CFArrayCreateMutable( kCFAllocatorDefault, 0,
									&kCFTypeArrayCallBacks );
    CFDictionaryApplyFunction( names, KeyArrayCallback, (void *)
							  langKeys );
    /* Get the preferred order of localizations */
    orderLangKeys = CFBundleCopyPreferredLocalizationsFromArray(langKeys);
    CFRelease( langKeys );
	
    if( orderLangKeys && CFArrayGetCount(orderLangKeys) )
    {
        langKey = (CFStringRef)CFArrayGetValueAtIndex( orderLangKeys, 0 );
        localName = (CFStringRef)CFDictionaryGetValue( names, langKey );
        CFRetain( localName );
    }
	CFRelease(langKey);
    CFRelease(orderLangKeys);
    CFRelease(dict);
    return localName;
}

//
//-------
//

@implementation OutputViewManager
@synthesize numberOutputViews, glViews;


-(id) init{
	if([super init]){
		setupScreensCalled = NO;
		
		glViews = [[[NSMutableArray alloc] init] retain];	
		outputViewsPanels = [[[NSMutableArray alloc] init] retain];	
		numberOutputViews = 1;
		fullscreen = NO;				
	}
	return self;
}

//
//-------
//Creates the panels with glviews inside
//

-(void) setupScreen{	
	int i;
	for(i=0;i<numberOutputViews;i++){
		
		OutputPanelController * newPanel = [[[OutputPanelController alloc] init] autorelease];
		[newPanel loadFromNib];
				
		[[newPanel panel] setStyleMask:NSResizableWindowMask | NSHUDWindowMask | NSTitledWindowMask | NSUtilityWindowMask];
		[[newPanel panel] setFrameAutosaveName:[NSString stringWithFormat:@"OutputView %i",i]];
		[[newPanel panel] setTitle:[NSString stringWithFormat:@"OutputView %i",i]];
		[[newPanel panel] setMinSize:NSMakeSize(800/4, (600/4)+40)];
		[[newPanel panel] setHidesOnDeactivate:NO];
		[[newPanel panel] setLevel:NSFloatingWindowLevel];
		
		[outputViewsPanels addObject:newPanel];
		
		[[newPanel glView] setController:controller];
		[[newPanel glView] setViewManager:self];
		[[newPanel glView] setViewNumber:i];
		[[newPanel glView] awakeFromNib];
		
		theDelegate = [[[PluginOutputWindowDelegate alloc]initWithPluginOutputView:[newPanel glView]]retain];
		[[newPanel panel] setDelegate:theDelegate];
		
		[glViews addObject:[newPanel glView]];
				
	}
	
	[self refreshScreens];
	
	
	for(OutputPanelController * panelController in outputViewsPanels){
		PluginOpenGLView * view = [panelController glView];
		NSPanel * panel = (NSPanel * )[view window];
		[view updateDisplayIDWithWindow:panel];
	}
	
	setupScreensCalled = YES;
	
	BOOL goFullscreen = YES;
	for(PluginOpenGLView * view in glViews){
		if([view displayId] == 0 ){//|| [view displayId] == CGMainDisplayID()){
			//Go not to fullscreen if a primary monitor is selected, or no monitor
			goFullscreen = NO;
		}		
	}	
	
	if(goFullscreen){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self goFullscreen];
		});
	}
}


//
//------
//Updates the popups for choosing display
//

-(void) refreshScreens{
	CGDisplayCount		dspCount = 0;
	CGDirectDisplayID *displays = nil;
	
	dspCount = [self getDisplayList:&displays];
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSLog(@"------ Display manager: -------");
	NSLog(@"	Total number of displays:%i", dspCount);
	
	int u=0;
	for(OutputPanelController * panel in outputViewsPanels){
		PluginOpenGLView * view = [panel glView];
		NSPopUpButton * popup = [panel displayPopup];
		
		[view setScreenSize:NSMakeSize(640, 480)];
		[popup removeAllItems];
		[popup addItemWithTitle:@"No display"];
		int i;
		for(i = 0; i < dspCount; i++)
		{	CFStringRef name = CopyLocalDisplayName(displays[i]) ;
			NSLog(@"	Display %i: %lux%lu %@",i, CGDisplayPixelsWide(displays[i]),CGDisplayPixelsHigh(displays[i]),  name);
			[popup addItemWithTitle:[NSString stringWithFormat:@"%i: %@ %ix%i", i,name, CGDisplayPixelsWide(displays[i]),CGDisplayPixelsHigh(displays[i])]];			
			if([[userDefaults valueForKey:[NSString stringWithFormat:@"DisplayIdForView%i",[view viewNumber]]] intValue] ==  displays[i]){
				[popup selectItem:[popup lastItem]];
				[view setDisplayNumber:popup];
			}
			CFRelease(name);
		}		
		u++;
	}	
	free(displays);
	
	NSLog(@"\n");
}


//
//------
//


-(void)setNumberOutputViews:(int)n{
	if(setupScreensCalled){
		NSLog(@"setNumberOutputViews cannot be called outside setupApp!");
	} else {
		numberOutputViews = n;
	}
}

//
//------
//

-(IBAction) goFullscreen{
	if(!fullscreen){
		[[controller openglLock] lock]; 
		
		[toolbarFullscreenItem setLabel:@"Window"];
		[toolbarFullscreenItem setImage:[NSImage imageNamed:@"NSExitFullScreenTemplate"]];
		
		fullscreen = YES;
		
		int i=0;
		for(OutputPanelController * panelController in outputViewsPanels){
			PluginOpenGLView * view = [panelController glView];
			if([view displayId] != 0){					
				NSPanel * panel = [panelController panel];
				NSScreen * screen;
				NSScreen * tmpScreen;
				//Find the screen to fullscreen on
				for(tmpScreen in [NSScreen screens]){
					if([view displayId] == [[[tmpScreen deviceDescription] valueForKey:@"NSScreenNumber"] intValue]){
						screen = tmpScreen;
					}
				}
				
				if(screen != nil){	
					if([view displayId] == CGMainDisplayID()){
						CGDisplayHideCursor (kCGNullDirectDisplay);	
					}
					
					NSRect fullDisplayRect = [screen frame];	
					[panel setFrameAutosaveName:@""];
					[panel setStyleMask:NSBorderlessWindowMask];
					[panel setBackingType:NSBackingStoreBuffered];
					[panel setLevel:NSMainMenuWindowLevel+1];
					[panel setOpaque:YES];
					[panel setHidesOnDeactivate:NO];
					
					[panel setFrame:fullDisplayRect display:YES];
					[panel makeKeyAndOrderFront:self];						
					[view setInFullscreen:YES];						
					[panel setTitle:[NSString stringWithFormat:@"OutputView %i",i]];
					
					[view setFrame:NSMakeRect(0, 0, fullDisplayRect.size.width, fullDisplayRect.size.height) ];
					
					[view updateDisplayIDWithWindow:panel];
					
					[[panelController displayPopup] setEnabled:NO];							
				}
			}
			i++;				
		}		
		[[controller openglLock] unlock]; 
		
	}
}

//
//------
//

-(IBAction) goWindow{
	CGDisplayShowCursor(kCGNullDirectDisplay);	
	
	if(fullscreen){	
		
		fullscreen = NO;
		
		
		[toolbarFullscreenItem setLabel:@"Fullscreen"];	
		[toolbarFullscreenItem setImage:[NSImage imageNamed:@"NSEnterFullScreenTemplate"]];
		
		int i=0;
		for(OutputPanelController * panelController in outputViewsPanels){
			[[controller openglLock] lock]; // prevent drawing from another thread if we're drawing already
			
			PluginOpenGLView * view = [panelController glView];
			
			NSPanel * panel = (NSPanel * )[view window];
			
			[panel setStyleMask:NSResizableWindowMask | NSHUDWindowMask | NSTitledWindowMask | NSUtilityWindowMask];
			[panel setLevel:NSFloatingWindowLevel];
			[panel setOpaque:NO];
			[panel setHidesOnDeactivate:NO];
			
			[panel setTitle:[NSString stringWithFormat:@"OutputView %i",i]];
			[panel setFrameAutosaveName:[NSString stringWithFormat:@"OutputView %i",i]];
			
			NSRect viewRect = [panel frame];
			viewRect.origin.x = 0;
			viewRect.origin.y = 52;
			viewRect.size.height -= 72;	
			[view setFrame:viewRect];
			
			
			[[panelController displayPopup] setEnabled:YES];
			[[controller openglLock] unlock]; // prevent drawing from another thread if we're drawing already
			
			[view updateDisplayIDWithWindow:panel];
			
			i++;	
		}
		
	}
	
}
-(IBAction) pressFullscreenButton:(id)sender{
	if(!fullscreen){
		[self goFullscreen];
	} else{
		[self goWindow];
	}
}

//
//-----
//

-(CGDisplayCount) getDisplayList:(CGDirectDisplayID **)displays{
	CGDisplayCount		dspCount = 0;
	CGError				err = CGDisplayNoErr;
	
	err = CGGetActiveDisplayList(0, NULL, &dspCount);	

	if(*displays != nil)
		free(*displays);
	
	*displays = (CGDirectDisplayID*) calloc((size_t)dspCount, sizeof(CGDirectDisplayID));	
	CGGetActiveDisplayList(dspCount, *displays, &dspCount);
	
	return dspCount;
}

//
//------
//


-(void) showViews{
	for(PluginOpenGLView * view in glViews){
		[[view window] display];
		[[view window] orderFront:self];
	}	
}

@end


//
//------
//


@implementation PluginOutputWindowDelegate

- (id) initWithPluginOutputView:(PluginOpenGLView*)thePOV{
	if ([super init]) {
		pov = thePOV;
	}
    return self;
}

- (NSSize)windowWillResize:(NSWindow *)window toSize: (NSSize)proposedFrameSize
{
	if( [pov screenSize].height == 0. || [pov screenSize].width == 0. )
		return proposedFrameSize;
	
	proposedFrameSize.width = (proposedFrameSize.height-50)*([pov screenSize].width/[pov screenSize].height);
	
	return proposedFrameSize;
}

@end