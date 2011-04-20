#pragma once
/*
 *  SharedContextLayer.h
 *
 *  Created by Jonas Jongejan on 24/11/09.
 *
 */

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#import "PluginManagerController.h"

@class ofPlugin;
extern PluginManagerController * globalController;

@interface SharedContextLayer : CAOpenGLLayer {	
	ofPlugin * plugin;
}

@end
