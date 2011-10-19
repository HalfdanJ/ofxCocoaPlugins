//
//  ofxCocoaPlugins.h
//  ofxCocoaPlugins
//
//  Created by Jonas Jongejan on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ofxCocoaPlugins : NSObject{
    NSObject * appDelegate;
}

- (id)initWithAppDelegate:(id)appDelegate;

@end
