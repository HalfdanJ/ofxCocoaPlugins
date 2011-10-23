//
//  ofxCocoaPlugins.m
//  ofxCocoaPlugins
//
//  Created by Jonas Jongejan on 10/19/11.
//

#import "ofxCocoaPlugins.h"
#import <AppKit/AppKit.h>


@implementation ofxCocoaPlugins

- (id)initWithAppDelegate:(id)_appDelegate
{
    self = [super init];
    if (self) {
        appDelegate = _appDelegate;
        
        
        //Load the mainmenu nib
        [NSBundle loadNibNamed:@"Application" owner:self];
    }
    
    return self;
}

@end
