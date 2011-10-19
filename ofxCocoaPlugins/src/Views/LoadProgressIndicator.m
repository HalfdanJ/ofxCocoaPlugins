#import "LoadProgressIndicator.h"


@implementation LoadProgressIndicator
@synthesize doubleValue;


-(id) initWithFrame:(NSRect)frameRect{
	[super initWithFrame:frameRect];
	
	
	CALayer *outline = [[CALayer layer] retain]; 
	{
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		CGFloat components[4] = {255/255.0, 255/255.0, 255/255.0, 0.5};
		CGColorRef color = CGColorCreate(colorSpace, components);
		outline.cornerRadius = 5.0;
		outline.borderColor = color;
		outline.borderWidth = 1.0;
		outline.bounds = [self layer].bounds;
		outline.frame = [self layer].frame;
		CGColorSpaceRelease(colorSpace);
		CGColorRelease(color);

	}
	


	
	CALayer *progress = [CALayer layer]; 
	{	
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		CGFloat components[4] = {255/255.0, 255/255.0, 255/255.0, 0.3};
		CGColorRef color = CGColorCreate(colorSpace, components);
		progress.backgroundColor = color; 
		progress.cornerRadius = 5.0;
		CGColorRelease(color);
		CGColorSpaceRelease(colorSpace);


	}
	
	
	progressView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0, frameRect.size.height)];
	[progressView setLayer:progress]; 
	[progressView setWantsLayer:YES];
	[self addSubview:progressView];

	[self setLayer:outline]; 
	[self setWantsLayer:YES];
	return self;
	
}

-(void) setDoubleValue:(double)d{
	doubleValue = d;
	[progressView  setFrame:NSMakeRect(0, 0, [self frame].size.width * doubleValue, [self frame].size.height)];
	
	[self setNeedsDisplay:YES];
}

-(void) drawRect:(NSRect)rect{

	[super drawRect:rect];
}
@end
