//
//  ExampleAppDelegate.m
//  Example
//
//  Created by Jonas Jongejan on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExamplePlugin.h"

#import "ExampleAppDelegate.h"

@implementation ExampleAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ocp = [[ofxCocoaPlugins alloc] initWithAppDelegate:self];
    [ocp addHeader:@"MyPlugins"];
    [ocp addPlugin:[[ExamplePlugin alloc] init]];
    [ocp loadPlugins];
}

@end
