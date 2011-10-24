#pragma once

#import <Cocoa/Cocoa.h>

@class PluginOpenGLView;

@interface OutputViewStats : NSView {
	NSNumber* fps;
	NSMutableArray * historyData;
}
@property (retain) NSNumber* fps;

-(id) initWithFrame:(NSRect)frameRect outputView:(PluginOpenGLView*)view;
-(void) addHistory:(NSNumber*)fps;
@end
