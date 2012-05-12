#import <Cocoa/Cocoa.h>

#import <ofxCocoaPlugins/PluginProperty.h>

@class PluginManagerController;
extern PluginManagerController * globalController;


@interface ColorProperty : PluginProperty {
    NSColor * color;
}

@property (readwrite) NSColor * color;

@end
