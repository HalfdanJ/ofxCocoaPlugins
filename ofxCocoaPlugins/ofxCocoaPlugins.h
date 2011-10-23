//
//  ofxCocoaPlugins.h
//  ofxCocoaPlugins
//
//  Created by Jonas Jongejan on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ofPlugin;

@interface ofxCocoaPlugins : NSObject{
    NSObject * appDelegate;
    IBOutlet NSObject * pluginManagerController;

}

- (id)initWithAppDelegate:(id)appDelegate;
- (void) addHeader:(NSString*)header;
- (void) addPlugin:(ofPlugin*)plugin;
- (void) loadPlugins;
@end
