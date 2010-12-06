#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#import "PluginOpenGLView.h"

@interface OutputPanelController : NSObject {
	IBOutlet NSPanel * panel;
	IBOutlet NSPopUpButton * displayPopup;
	IBOutlet PluginOpenGLView * glView;
	IBOutlet NSSlider * scaleSlider;
}
@property (readonly, retain) NSSlider * scaleSlider;
@property (readonly, retain) NSPanel * panel;
@property (readonly, retain) NSPopUpButton * displayPopup;
@property (readonly, retain) PluginOpenGLView * glView;

-(void)loadFromNib;

@end
