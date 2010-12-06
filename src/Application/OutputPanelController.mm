//
//  OutputViewPanel.m
//  kronborg
//
//  Created by Jonas Jongejan on 23/09/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "OutputPanelController.h"


@implementation OutputPanelController
@synthesize panel;
@synthesize displayPopup, glView, scaleSlider;

-(void)loadFromNib{
	if(![NSBundle loadNibNamed:@"OutputPanel" owner:self]){
		NSLog(@"Could not load outputview xib");
	}
}

@end
