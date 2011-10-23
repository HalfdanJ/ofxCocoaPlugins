//
//  ExampleAppDelegate.h
//  Example
//
//  Created by Jonas Jongejan on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <ofxCocoaPlugins/ofxCocoaPlugins.h>
#import <Cocoa/Cocoa.h>

@interface ExampleAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    ofxCocoaPlugins *ocp;
}

@property (assign) IBOutlet NSWindow *window;

@end
