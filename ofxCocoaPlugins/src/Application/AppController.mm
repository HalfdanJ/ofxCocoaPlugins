//
//  AppController.m
//
//  Created by Jonas Jongejan on 03/11/09.
//

#import "AppController.h"
//#include "PluginIncludes.h"
#include "CorePluginsIncludes.h"
//#include "testApp.h"
#include "ofAppCocoaWindow.h"


@implementation AppController

-(void) setupApp{
	[pluginManagerController setNumberOutputViews:1];	
}


-(void) awakeFromNib {
	//ofSetBackgroundAuto(false);
}

-(void) setupPlugins{
	[pluginManagerController addHeader:@"Plugins"];
	[pluginManagerController addPlugin:[[Midi alloc] init]];

}

@end
