#import "PluginManagerController.h"

#import "ofxCocoaPlugins.h"
#import <AppKit/AppKit.h>


@implementation ofxCocoaPlugins

- (id)initWithAppDelegate:(id)_appDelegate
{
    self = [super init];
    if (self) {
        appDelegate = _appDelegate;
        
        
        //Load the mainmenu nib
        [NSBundle loadNibNamed:@"Application" owner:self];
    }
    
    return self;
}

- (void) addHeader:(NSString*)header{
    [(PluginManagerController*)pluginManagerController addHeader:header];

}
- (void) addPlugin:(ofPlugin*)plugin{
	[(PluginManagerController*)pluginManagerController addPlugin:plugin];
}

- (void)loadPlugins{
    [(PluginManagerController*)pluginManagerController finishedDefinePlugins];
}


@end
