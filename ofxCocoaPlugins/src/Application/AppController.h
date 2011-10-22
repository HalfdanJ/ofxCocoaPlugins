//
//  AppController.h
//
//  Created by Jonas Jongejan on 03/11/09.
//
#import "GL/glew.h"

#import <Cocoa/Cocoa.h>
#include "PluginManagerController.h"
#include "ofBaseApp.h"
#include "ofAppBaseWindow.h"


@interface AppController : NSObject/* Specify a superclass (eg: NSObject or NSView) */ {
	IBOutlet NSView * mainView;
	IBOutlet PluginManagerController * pluginManagerController;
	
	
	ofBaseApp * baseApp;
	ofAppBaseWindow * cocoaWindow;

}

-(void) setupPlugins;
-(void) setupApp;

@end
