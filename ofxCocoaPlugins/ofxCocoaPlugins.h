#import <Foundation/Foundation.h>
#import <ofxCocoaPlugins/CorePluginsIncludes.h>
#import <ofxCocoaPlugins/CustomGraphics.h>

@class ofPlugin;

@interface ofxCocoaPlugins : NSObject{
    NSObject * appDelegate;
    IBOutlet NSObject * pluginManagerController;
}

- (id)initWithAppDelegate:(id)appDelegate;

//Use these to add plugins and headers to the app
- (void) addHeader:(NSString*)header;
- (void) addPlugin:(ofPlugin*)plugin;
- (void) addPlugin:(ofPlugin*)plugin midiChannel:(int)channel;

//Set the number of opengl outputviews. Default = 1
- (void) setNumberOutputviews:(int)views;

//Call this when you have added all plugins
- (void) loadPlugins;

@end
