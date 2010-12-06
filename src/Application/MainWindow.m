//
//  MainWindow.mm
//  simpleExample
//
//  Created by Jonas Jongejan on 26/02/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "MainWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadProgressIndicator.h"

@implementation MainWindow

-(id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag{
	[super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	loadingState = YES;
	
}



-(void)fadeOverlayIn {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.25f];
	[[topView animator] setAlphaValue:0.8];
	[NSAnimationContext endGrouping];
}

-(void)fadeOverlayOut {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.5f];
	[[topView animator] setAlphaValue:0];
	[NSAnimationContext endGrouping];
	[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(finishedFadeLoading) userInfo:nil repeats:NO];
}


-(void) awakeFromNib{
	[super awakeFromNib];
	[[self contentView] setWantsLayer:NO];
	if(loadingState){
		{		
			topView = [[NSView alloc] initWithFrame:[[self contentView] frame]];
			
			CALayer *coverlayer = [CALayer layer]; 
			CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
			CGFloat components[4] = {133/255.0, 133/255.0, 127/255.0, 1.0};
			CGColorRef color = CGColorCreate(colorSpace, components);
			coverlayer.backgroundColor = color; 
			
		
			[topView setLayer:coverlayer]; 
			[topView setWantsLayer:YES];
			CGColorRelease(color);
			CGColorSpaceRelease(colorSpace);
		}
		
		
		//Loading window
		{
			float w = 300;
			float h = 65;	
			NSRect rect = NSMakeRect([[self contentView] frame].size.width / 2.0 - w/2.0, 
									 [[self contentView] frame].size.height / 2.0 - h/2.0,
									 w,
									 h);		
			
			statusView = [[NSView alloc] initWithFrame:rect];
			
			
			NSRect indicatorRect = NSMakeRect(w/2.0-130, 10, 260, 20);		
			loadIndicator = [[LoadProgressIndicator alloc] initWithFrame:indicatorRect];
			[loadIndicator setDoubleValue:0.0];
			[statusView addSubview:loadIndicator];
			
			NSRect textRect = NSMakeRect(w/2.0-130, 33, 260, 20);		
			loadText = [[NSTextField alloc] initWithFrame:textRect];
			[loadText setEditable:NO];
			[loadText setBordered:NO];
			[loadText setDrawsBackground:NO];
			[loadText setTextColor:[NSColor whiteColor]];
			[loadText setStringValue:@"Loading..."];
			[statusView addSubview:loadText];
			
			
			CALayer *coverlayer = [CALayer layer]; 
			CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
			CGFloat components[4] = {75/255.0, 75/255.0, 75/255.0, 0.8};
			CGColorRef color = CGColorCreate(colorSpace, components);
			coverlayer.backgroundColor = color; 
			coverlayer.cornerRadius = 20.0;
			coverlayer.shadowOpacity = 0.3;
			
			
			[statusView setLayer:coverlayer]; 
			[statusView setWantsLayer:YES];
			CGColorRelease(color);
			CGColorSpaceRelease(colorSpace);
		}
		
		
		[[self contentView] addSubview:topView];
		[topView addSubview:statusView];
		[self fadeOverlayIn];		
	}
 
}

-(void) setFinishedLoading{
	[self fadeOverlayOut];
	loadingState = NO;
}

-(void) finishedFadeLoading{
	
}

-(void) setLoadStatusText:(NSString*)text{
	[loadText setStringValue:text];
}

-(void)	setLoadPercentage:(float)percentage{
	[loadIndicator setDoubleValue:percentage];		
}

-(void) sendEvent:(NSEvent *)theEvent{
	if(!loadingState){
		[super sendEvent:theEvent];
	}
}


@end
