#include "GL/glew.h"

#import <Cocoa/Cocoa.h>
#include "PluginProperty.h"

#include "PluginManagerController.h"

@class PluginManagerController;
extern PluginManagerController * globalController;

@interface BoolProperty : PluginProperty {
	

}
+(BoolProperty*)boolPropertyWithDefaultvalue:(BOOL)defValue;
@end
