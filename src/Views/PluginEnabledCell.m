//
//  PluginEnabledCell.m
//  simpleExample
//
//  Created by Jonas Jongejan on 28/02/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "PluginEnabledCell.h"


@implementation PluginEnabledCell
-(void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	if([self isEditable]){	
		[super drawWithFrame:cellFrame inView:controlView];
	}
}
@end
