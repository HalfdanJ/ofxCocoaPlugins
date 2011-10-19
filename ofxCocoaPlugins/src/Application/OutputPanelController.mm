//
//  OutputViewPanel.m
//
//  Created by Jonas Jongejan on 23/09/10.
//

#import "OutputPanelController.h"


@implementation OutputPanelController
@synthesize panel, displayPopup, glView;

-(void)loadFromNib{
	if(![NSBundle loadNibNamed:@"OutputPanel" owner:self]){
		NSLog(@"Could not load outputview nibfile");
	}
}

@end
