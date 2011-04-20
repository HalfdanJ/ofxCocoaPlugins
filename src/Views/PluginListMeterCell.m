//
//  PluginListMeterCell.m
//  simpleExample
//
//  Created by LoadNLoop on 19/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PluginListMeterCell.h"


@implementation PluginListMeterCell

-(id) init{
	if([super init]){
		
	}
	return self;
}



- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if([[[self objectValue] valueForKey:@"show"] boolValue]){
		float cpu = [[[self objectValue] valueForKey:@"cpu"] floatValue];
		float gpu = [[[self objectValue] valueForKey:@"gpu"] floatValue];
		if(cpu < 1){
			if([self isHighlighted]){
				[[NSColor whiteColor] set];
			} else {
				[[NSColor colorWithCalibratedRed:250/255.0 green:184/255.0 blue:32/255.0 alpha:0.5] set];
			}
			[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y+5, (cellFrame.size.width-10)*cpu, 5) xRadius:0 yRadius:0] fill];
		}
		
		if(gpu < 1){
			if([self isHighlighted]){
				[[NSColor whiteColor] set];
			} else {
				[[NSColor colorWithCalibratedRed:255/255.0 green:105/255.0 blue:7/255.0 alpha:0.5] set];
			}
			[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y+10, (cellFrame.size.width-10)*gpu, 5) xRadius:0 yRadius:0] fill];
		}
		
		
		if([self isHighlighted]){
			[[NSColor whiteColor] set];
		} else {
			[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
		}
		[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y+5, cellFrame.size.width-10, 10) xRadius:2 yRadius:2] stroke];
	}
}
@end
