#pragma once
#include "GLee.h"

#import <Cocoa/Cocoa.h>

#include "PluginProperty.h"

@interface QLabController : NSObject {
	IBOutlet NSPanel * panel;

	NSMutableArray * cues;
	PluginProperty * linkedProperty;
}
@property (readwrite,retain) NSMutableArray * cues;
@property (readwrite,retain) PluginProperty * linkedProperty;

-(void) startQlabTransaction:(PluginProperty*)proptery;

@end
