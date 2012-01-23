#pragma once

#import <Cocoa/Cocoa.h>
#import <ofxCocoaPlugins/PluginOpenGLView.h>

//OutputPanelController creates the output opengl views from nib
@interface OutputPanelController : NSObject {
	IBOutlet NSPanel * panel;
	IBOutlet NSPopUpButton * displayPopup;
	IBOutlet PluginOpenGLView * glView;
}

@property (readonly, retain) NSPanel * panel;
@property (readonly, retain) NSPopUpButton * displayPopup;
@property (readonly, retain) PluginOpenGLView * glView;

-(void)loadFromNib;

@end
