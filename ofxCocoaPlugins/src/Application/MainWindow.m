#import "MainWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadProgressIndicator.h"

//Loading box viewsize
const float w = 300;
const float h = 65;	


@implementation MainWindow

-(id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag{
	
	loadingState = YES;
	return [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
}


//
//-------
//Loading box fadein


-(void)fadeOverlayIn {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.25f];
	[[topView animator] setAlphaValue:0.8];
	[NSAnimationContext endGrouping];
}

//
//-------
//

-(void)fadeOverlayOut {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.5f];
	[[topView animator] setAlphaValue:0];
	[NSAnimationContext endGrouping];
}

//
//-------
//

-(void) awakeFromNib{
	[super awakeFromNib];
	[[self contentView] setWantsLayer:NO];
    
    //Create loading view
	if(loadingState){
		{		
			topView = [[NSView alloc] initWithFrame:[[self contentView] frame]];
			
			CALayer *coverlayer = [CALayer layer]; 
			CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
			CGFloat components[4] = {0.2, 0.2, 0.21, 1.0};
			CGColorRef color = CGColorCreate(colorSpace, components);
			coverlayer.backgroundColor = color; 
			
		
			[topView setLayer:coverlayer]; 
			[topView setWantsLayer:YES];
			CGColorRelease(color);
			CGColorSpaceRelease(colorSpace);
		}
		
        {
			NSRect rect = NSMakeRect([[self contentView] frame].size.width / 2.0 - w/2.0, 
									 [[self contentView] frame].size.height / 2.0 - h/2.0,
									 w,
									 h);		
			
			statusView = [[NSView alloc] initWithFrame:rect];
			
			

			
			NSRect indicatorRect = NSMakeRect(w/2.0-130, 10, 260, 20);		
			loadIndicator = [[LoadProgressIndicator alloc] initWithFrame:indicatorRect];
			[loadIndicator setDoubleValue:0.0];
			[loadIndicator setAutoresizingMask:NSViewMinYMargin ];
			[statusView addSubview:loadIndicator];
			
			
			NSRect textRect = NSMakeRect(w/2.0-130, 33, 260, 20);		
			loadText = [[NSTextField alloc] initWithFrame:textRect];
			[loadText setEditable:NO];
			[loadText setBordered:NO];
			[loadText setDrawsBackground:NO];
			[loadText setTextColor:[NSColor whiteColor]];
			[loadText setStringValue:@"Starting..."];
			[loadText setAutoresizingMask:NSViewMinYMargin ];
			[statusView addSubview:loadText];
			
			
			CALayer *coverlayer = [CALayer layer]; 
			CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
			CGFloat components[4] = {0.1, 0.1, 0.12, 0.8};
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

//
//-------
//

-(void) setFinishedLoading{
	[self fadeOverlayOut];
	loadingState = NO;
}

//
//-------
//

-(void) setLoadStatusText:(NSString*)text{
	[loadText setStringValue:text];
}

//
//-------
//

-(void)	setLoadPercentage:(float)percentage{
	[loadIndicator setDoubleValue:percentage];		
}

//
//-------
//

-(void) addPluginDetail:(NSString*)name text:(NSString*)text  {
	int _h = 14;
	NSRect frame = [statusView frame];
	frame.size.height += _h;
	frame.origin.y -= _h/2;
	[statusView setFrame:frame];
	
	NSRect textRect = NSMakeRect(w/2.0-130, 0, 100, 20);		
	NSTextField * detailText = [[NSTextField alloc] initWithFrame:textRect];
	[detailText setAutoresizingMask:NSViewMinYMargin ];
	[detailText setEditable:NO];
	[detailText setFont:[NSFont systemFontOfSize:10]]; 
	[detailText setBordered:NO];
	[detailText setDrawsBackground:NO];
	[detailText setTextColor:[NSColor whiteColor]];
	[detailText setStringValue:[NSString stringWithFormat:@"%@:",name]];
	[detailText setAlignment:NSRightTextAlignment];
	[detailText setAutoresizingMask:NSViewMinYMargin ];
	[statusView addSubview:detailText];
	
	NSRect textRect2 = NSMakeRect(w/2.0-30, 0, 160, 20);		
	NSTextField * detailText2 = [[NSTextField alloc] initWithFrame:textRect2];
	[detailText2 setAutoresizingMask:NSViewMinYMargin ];
	[detailText2 setEditable:NO];
	[detailText2 setFont:[NSFont userFontOfSize:10]]; 
	[detailText2 setBordered:NO];
	[detailText2 setDrawsBackground:NO];
	[detailText2 setTextColor:[NSColor whiteColor]];
	[detailText2 setStringValue:text];
	[detailText2 setAutoresizingMask:NSViewMinYMargin ];
	[statusView addSubview:detailText2];
	
}

//
//-------
//

-(void) setPluginDetailNumber:(int)n to:(NSString*)s{
	[[[statusView subviews] objectAtIndex:n*2+3] setStringValue:s];
	[[[statusView subviews] objectAtIndex:n*2+3] setNeedsDisplay:YES];
}

//
//-------
//

-(void) sendEvent:(NSEvent *)theEvent{
	if(!loadingState){
		[super sendEvent:theEvent];
	}
}

@end
