//

#import <Cocoa/Cocoa.h>
#import <ofxCocoaPlugins/PluginProperty.h>
//#include "PluginProperty.h"

@class PluginManagerController;
extern PluginManagerController * globalController;

@interface BoolProperty : PluginProperty {
	

}

@property (readwrite) BOOL boolValue;

+(BoolProperty*)boolPropertyWithDefaultvalue:(BOOL)defValue;
@end
