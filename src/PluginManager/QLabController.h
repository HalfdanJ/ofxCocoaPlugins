#pragma once
#include "GLee.h"

#import <Cocoa/Cocoa.h>

#include "PluginProperty.h"
#include "Plugin.h"

@interface QLabController : NSObject {
	IBOutlet NSPanel * panel;
	IBOutlet NSButton * addButton;
	IBOutlet NSButton * cancelButton;

	NSMutableArray * cues;
	PluginProperty * linkedProperty;
}
@property (readwrite,retain) NSMutableArray * cues;
@property (readwrite,retain) PluginProperty * linkedProperty;

-(IBAction) addCue:(id)sender;
-(IBAction) cancel:(id)sender;

-(void) startQlabTransaction:(PluginProperty*)proptery;
-(void) sendQlabAddCue:(NSString*)name  channel:(NSNumber*)channel control:(NSNumber*)control value:(NSNumber*)value fade:(bool)fade fadeTo:(int)fadeTo;

-(void) assignMidiSettingsForPlugin:(ofPlugin*)plugin;
@end
