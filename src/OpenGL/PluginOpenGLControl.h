//
//  PluginOpenGLLayer.h
//
//  Created by Jonas Jongejan on 19/11/09.
//

#pragma once 

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "Plugin.h"

@interface PluginOpenGLControlView : NSView {	
}
@end


@interface PluginOpenGLControl : SharedContextLayer {
	NSMutableDictionary * drawingInformation;
}
@property (assign, readwrite) ofPlugin * plugin;



@end
