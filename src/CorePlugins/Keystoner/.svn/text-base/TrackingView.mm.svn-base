//
//  TrackingView.m
//  loadnloop
//
//  Created by Jonas Jongejan on 25/03/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "TrackingView.h"


@implementation TrackingView

-(void) scrollWheel:(NSEvent *)theEvent{
	[[self layer] scrollWheel:theEvent];
}

-(void) mouseDragged:(NSEvent *)event{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	CGPoint cgLocation = NSPointToCGPoint(location);
	
	[[self layer] mouseDragged:cgLocation];
	[super mouseDragged:event];
}	

-(void) mouseDown:(NSEvent *)event{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	CGPoint cgLocation = NSPointToCGPoint(location);
	[[self layer] mouseDown:cgLocation];
	[super mouseDown:event];
}

-(void) keyDown:(NSEvent *)theEvent{
	NSLog(@"%@",theEvent);
	[[self layer] keyDown:theEvent];
}


-(BOOL) becomeFirstResponder{
	NSLog(@"yay");
	return YES;	
}
-(BOOL) acceptsFirstResponder{
	return YES;
}
@end
