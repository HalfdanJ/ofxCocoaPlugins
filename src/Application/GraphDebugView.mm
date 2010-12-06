//
//  GraphDebugView.m
//  simpleExample
//
//  Created by Jonas Jongejan on 09/03/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "GraphDebugView.h"


@implementation GraphDebugView
@synthesize xMax, xMin, xRangeMin, xRangeMax, yMax, yMin, yRangeMin, yRangeMax;

-(id) initWithFrame:(NSRect)frameRect{
	if([super initWithFrame:frameRect]){
		mouseEvent = NoMouseEvent;	
	/*	[self addObserver:self forKeyPath:@"yRangeMin" options:NSKeyValueObservingOptionNew context:@"updateLeftScroller"];
		[self addObserver:self forKeyPath:@"yRangeMax" options:NSKeyValueObservingOptionNew context:@"updateLeftScroller"];
		[self addObserver:self forKeyPath:@"yMin" options:NSKeyValueObservingOptionNew context:@"updateLeftScroller"];
		[self addObserver:self forKeyPath:@"yMax" options:NSKeyValueObservingOptionNew context:@"updateLeftScroller"];*/
		[self addObserver:self forKeyPath:@"xRangeMin" options:NSKeyValueObservingOptionNew context:@"updateBottomScroller"];
		[self addObserver:self forKeyPath:@"xRangeMax" options:NSKeyValueObservingOptionNew context:@"updateBottomScroller"];
		[self addObserver:self forKeyPath:@"xMin" options:NSKeyValueObservingOptionNew context:@"updateBottomScroller"];
		[self addObserver:self forKeyPath:@"xMax" options:NSKeyValueObservingOptionNew context:@"updateBottomScroller"];
		
	}
	return self;
}


-(void) awakeFromNib{
	float scrollerWidth = 15;
	
	CGRect viewFrame = NSRectToCGRect( self.frame );
	viewFrame.origin.y = 0;
	
	self.wantsLayer = YES;
	CALayer* mainLayer = self.layer;
	mainLayer.name = @"mainLayer";
	mainLayer.frame = viewFrame;
	mainLayer.delegate = self;
	[mainLayer setNeedsDisplay];
	
	
	
	CGFloat midX = CGRectGetMidX( mainLayer.frame );
	CGFloat midY = CGRectGetMidY( mainLayer.frame );
	
	// create a "container" layer for all content layers.
	// same frame as the view's master layer, automatically
	// resizes as necessary.    
	contentContainer = [CALayer layer];    
	contentContainer.bounds           = mainLayer.bounds;
	contentContainer.delegate         = self;
	contentContainer.anchorPoint      = CGPointMake(0.5,0.5);
	contentContainer.position         = CGPointMake( midX, midY );
	contentContainer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	[contentContainer setLayoutManager:[CAConstraintLayoutManager layoutManager]];    
	[self.layer addSublayer:contentContainer];
	
	
	//Black background
	CALayer * backgroundLayer = [CALayer layer];
	backgroundLayer.name			= @"background";
	backgroundLayer.backgroundColor = CGColorCreateGenericRGB(0.0f,0.0f,0.0f,1.0f);
	backgroundLayer.bounds           = mainLayer.bounds;
	backgroundLayer.position         = CGPointMake( midX, midY );
	backgroundLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	//[contentContainer addSublayer:backgroundLayer];
	
	
	//Left scroller area
	/*leftScrollerArea = [CALayer layer];
	leftScrollerArea.name			= @"leftScrollerArea";	
	leftScrollerArea.autoresizingMask	= kCALayerHeightSizable;
	leftScrollerArea.anchorPoint		= CGPointMake(0, 0);
	leftScrollerArea.bounds				= CGRectMake(0, 0, scrollerWidth,  mainLayer.bounds.size.height-24);
	leftScrollerArea.position			= CGPointMake( 3,20);
	leftScrollerArea.borderColor		= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	leftScrollerArea.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.2f);
	leftScrollerArea.borderWidth		= 2;
	leftScrollerArea.cornerRadius		= 7;
	leftScrollerArea.masksToBounds	= YES;	
	[contentContainer addSublayer:leftScrollerArea];
	
	//Left scroller Marked Area
	leftScrollerMarkedArea = [CAScrollLayer layer];
	leftScrollerMarkedArea.name			= @"leftScrollermarkedArea";	
	leftScrollerMarkedArea.autoresizingMask	= kCALayerHeightSizable;
	leftScrollerMarkedArea.anchorPoint		= CGPointMake(0, 0);
	leftScrollerMarkedArea.bounds			= CGRectMake(0, 0, scrollerWidth,  leftScrollerArea.bounds.size.height);
	leftScrollerMarkedArea.position			= CGPointMake( 0,0 );
	leftScrollerMarkedArea.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	leftScrollerMarkedArea.borderColor		= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	leftScrollerMarkedArea.cornerRadius		= 7;
	leftScrollerMarkedArea.borderWidth		= 2;	
	[leftScrollerArea addSublayer:leftScrollerMarkedArea];
	*/
	
	
	//Bottom scroller area
	bottomScrollerArea = [CALayer layer];
	bottomScrollerArea.name			= @"leftScrollerArea";	
	bottomScrollerArea.autoresizingMask	= kCALayerWidthSizable;
	bottomScrollerArea.anchorPoint		= CGPointMake(0, 0);
	bottomScrollerArea.bounds			= CGRectMake(0, 0, mainLayer.bounds.size.width-34, scrollerWidth);
	bottomScrollerArea.position			= CGPointMake(20, 3);
	bottomScrollerArea.borderColor		= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	bottomScrollerArea.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.2f);
	bottomScrollerArea.borderWidth		= 2;
	bottomScrollerArea.cornerRadius		= 7;
	bottomScrollerArea.masksToBounds	= YES;	
	[contentContainer addSublayer:bottomScrollerArea];
	
	//Bottom scroller Marked Area
	bottomScrollerMarkedArea = [CAScrollLayer layer];
	bottomScrollerMarkedArea.name			= @"bottomScrollermarkedArea";	
	bottomScrollerMarkedArea.autoresizingMask	= kCALayerWidthSizable;
	bottomScrollerMarkedArea.anchorPoint		= CGPointMake(0, 0);
	bottomScrollerMarkedArea.bounds			= CGRectMake(0, 0, bottomScrollerArea.bounds.size.width, scrollerWidth);
	bottomScrollerMarkedArea.position			= CGPointMake( 0,0 );
	bottomScrollerMarkedArea.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	bottomScrollerMarkedArea.borderColor		= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	bottomScrollerMarkedArea.cornerRadius		= 7;
	bottomScrollerMarkedArea.borderWidth		= 2;	
	[bottomScrollerArea addSublayer:bottomScrollerMarkedArea];
	/*
	
	//Left line
	CALayer * leftLine = [CALayer layer];
	leftLine.name = @"Leftline";
	leftLine.autoresizingMask	= kCALayerHeightSizable;
	leftLine.anchorPoint		= CGPointMake(0, 0);
	leftLine.bounds			= CGRectMake(0, 0, 1, contentContainer.bounds.size.height);
	leftLine.position			= CGPointMake( 45,23 );
	leftLine.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,1.0f);
	[contentContainer addSublayer:leftLine];
	
	//bottom line
	CALayer * bottomLine = [CALayer layer];
	bottomLine.name = @"Bottomline";
	bottomLine.autoresizingMask	= kCALayerWidthSizable;
	bottomLine.anchorPoint		= CGPointMake(0, 0);
	bottomLine.bounds			= CGRectMake(0, 0,contentContainer.bounds.size.width, 1);
	bottomLine.position			= CGPointMake( 23,45 );
	bottomLine.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,1.0f);
	[contentContainer addSublayer:bottomLine];
	
	
	//Left Value Area
	leftValueArea = [CALayer layer];
	leftValueArea.autoresizingMask	= kCALayerHeightSizable;
	leftValueArea.anchorPoint		= CGPointMake(0, 0);
	leftValueArea.bounds			= CGRectMake(0, 0, 25, contentContainer.bounds.size.height-45);
	leftValueArea.position			= CGPointMake( 20,45 );
	leftValueArea.backgroundColor	= CGColorCreateGenericRGB(1.0f,0.0f,0.0f,0.0f);
	[contentContainer addSublayer:leftValueArea];
	
	
	//Bottom Value Area
	bottomValueArea = [CALayer layer];
	bottomValueArea.autoresizingMask	= kCALayerWidthSizable;
	bottomValueArea.anchorPoint		= CGPointMake(0, 0);
	bottomValueArea.bounds			= CGRectMake(0, 0, contentContainer.bounds.size.width-45,25);
	bottomValueArea.position			= CGPointMake(45, 20 );
	bottomValueArea.backgroundColor	= CGColorCreateGenericRGB(1.0f,0.0f,0.0f,0.0f);
	[contentContainer addSublayer:bottomValueArea];
	
	
	*/
	
	
	
	
	
	
	[contentContainer layoutSublayers];
	[contentContainer layoutIfNeeded]; 	
	
	
}


-(void) resizeWithOldSuperviewSize:(NSSize)oldSize{
	[super resizeWithOldSuperviewSize:oldSize];
//	[self updateLeftScroller];
	[self updateBottomScroller];
	
}


- (void) mouseDown: (NSEvent *) event {
	mouseEvent = NoMouseEvent;
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	CGPoint cgLocation = NSPointToCGPoint(location);
	
	CALayer *layer = [self.layer hitTest:NSPointToCGPoint(location)];
	
	if([[layer name] isEqualToString:@"leftScrollermarkedArea"]){
		CGPoint scrollerPoint = [contentContainer convertPoint:cgLocation toLayer:leftScrollerMarkedArea];
		if(scrollerPoint.y < 15){
			mouseEvent = LeftScrollerMouseBottom;
			offsetDragPoint = [contentContainer convertPoint:cgLocation toLayer:leftScrollerMarkedArea];
		} else if(scrollerPoint.y > leftScrollerMarkedArea.bounds.size.height-15){
			mouseEvent = LeftScrollerMouseTop;	
			offsetDragPoint = CGPointMake(0, [contentContainer convertPoint:cgLocation toLayer:leftScrollerMarkedArea].y - leftScrollerMarkedArea.bounds.size.height);
		}	
	} else	if([[layer name] isEqualToString:@"bottomScrollermarkedArea"]){
		CGPoint scrollerPoint = [contentContainer convertPoint:cgLocation toLayer:bottomScrollerMarkedArea];
		if(scrollerPoint.x < 15){
			mouseEvent = BottomScrollerMouseLeft;
			offsetDragPoint = [contentContainer convertPoint:cgLocation toLayer:bottomScrollerMarkedArea];
		} else if(scrollerPoint.x > bottomScrollerMarkedArea.bounds.size.width-15){
			mouseEvent = BottomScrollerMouseRight;	
			offsetDragPoint = CGPointMake(0, [contentContainer convertPoint:cgLocation toLayer:bottomScrollerMarkedArea].x - bottomScrollerMarkedArea.bounds.size.width);
		}	
	}
	//	NSLog(@"Event: %i", mouseEvent);	
	
}

-(void) mouseDragged:(NSEvent *)event{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	CGPoint cgLocation = NSPointToCGPoint(location);
	
	if(mouseEvent == LeftScrollerMouseTop || mouseEvent == LeftScrollerMouseBottom ){
		CGPoint scrollerPoint = [contentContainer convertPoint:cgLocation toLayer:leftScrollerArea];;
		float point = (scrollerPoint.y - offsetDragPoint.y) ;
		point /= leftScrollerArea.bounds.size.height;
		point *= [[self yMax]floatValue] - [[self yMin]floatValue];
		point += [[self yMin]floatValue];
		point = MIN(point, [[self yMax]floatValue]);
		point = MAX(point, [[self yMin]floatValue]);
		switch (mouseEvent) {
			case LeftScrollerMouseBottom:
				point = MIN(point, [[self yRangeMax]floatValue]-0.06*([[self yMax]floatValue] - [[self yMin]floatValue]));
				if(point == 0)
					point = 0.00000000001;
				[self setYRangeMin:[NSNumber numberWithFloat:point]];
				break;
			case LeftScrollerMouseTop:	
				point = MAX(point, [[self yRangeMin]floatValue]+0.06*([[self yMax]floatValue] - [[self yMin]floatValue]));
				[self setYRangeMax:[NSNumber numberWithFloat:point]];
				break;
				
			default:
				break;
		}
		
		
	}
	
	
	if(mouseEvent == BottomScrollerMouseLeft || mouseEvent == BottomScrollerMouseRight ){
		CGPoint scrollerPoint = [contentContainer convertPoint:cgLocation toLayer:bottomScrollerArea];;
		float point = (scrollerPoint.x - offsetDragPoint.x) ;
		point /= bottomScrollerArea.bounds.size.width;
		point *= [[self xMax]floatValue] - [[self xMin]floatValue];
		point += [[self xMin]floatValue];
		point = MIN(point, [[self xMax]floatValue]);
		point = MAX(point, [[self xMin]floatValue]);
		
		switch (mouseEvent) {
			case BottomScrollerMouseLeft:
				point = MIN(point, [[self xRangeMax]floatValue]-0.06*([[self xMax]floatValue] - [[self xMin]floatValue]));
				[self setXRangeMin:[NSNumber numberWithFloat:point]];
				break;
			case BottomScrollerMouseRight:	
				point = MAX(point, [[self xRangeMin]floatValue]+0.06*([[self xMax]floatValue] - [[self xMin]floatValue]));
				[self setXRangeMax:[NSNumber numberWithFloat:point]];
				break;
				
			default:
				break;
		}
		
		
	}
	
}

-(void) mouseUp:(NSEvent *)theEvent{
	mouseEvent = NoMouseEvent;
}

-(void) updateLeftScroller{
	//	NSLog(@"Update left");
	[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:@"animationDuration"];
	
	float min = ([[self yRangeMin] floatValue] - [[self yMin]floatValue])  /   ( [[self yMax]floatValue] - [[self yMin]floatValue])  ;
	min *= leftScrollerArea.bounds.size.height;
	
	float max = ([[self yRangeMax] floatValue] - [[self yRangeMin]floatValue])  /   ( [[self yMax]floatValue] - [[self yMin]floatValue])  ;
	max *= leftScrollerArea.bounds.size.height;
	
	leftScrollerMarkedArea.position = CGPointMake(leftScrollerMarkedArea.position.x, min);
	leftScrollerMarkedArea.bounds = CGRectMake(0,0, leftScrollerMarkedArea.bounds.size.width, max);
	/*
	NSMutableArray * numbers = [[NSMutableArray arrayWithCapacity:100] retain];
	double resolution = 1024; 
	float i = 0;
	float size = leftValueArea.bounds.size.height;
	float delta = ([[self yRangeMax] floatValue] - [[self yRangeMin]floatValue]);
	while (size / ( delta / resolution) > 30 && resolution > 0.001 ) {
		resolution /= 2.0;
		if(i++ > 100)
			break;
	}
	
	//	int start = ceil( [[self yRangeMin] floatValue] * resolution) / resolution;
	for( i=0 ; i<[[self yRangeMax] floatValue] ; i+= resolution){
		if([[self yRangeMin] floatValue] < i)
			[numbers addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:i],@"value",[NSNumber numberWithBool:NO],@"found",nil]];
	}
	
	CATextLayer * curLayer;
	for(i=0;i<[[leftValueArea sublayers] count];i++){
		curLayer = [[leftValueArea sublayers] objectAtIndex:i];
		if([[curLayer string] floatValue] > [[self yRangeMax] floatValue] || [[curLayer string] floatValue] < [[self yRangeMin] floatValue]){
			[curLayer removeFromSuperlayer];
		} else {
			NSMutableDictionary * number;
			BOOL foundANumber = NO;
			for(number in numbers){
				if([[[number valueForKey:@"value"] stringValue] isEqualToString: [curLayer string]] ){
					if([[number valueForKey:@"found"] isEqualToNumber:[NSNumber numberWithBool:YES]]){
						[curLayer setOpacity:0];
						[curLayer removeFromSuperlayer];	
					}
					foundANumber = YES;
					float pos = ([[number valueForKey:@"value"] floatValue] - [[self yRangeMin]floatValue])  /   ( [[self yRangeMax]floatValue] - [[self yRangeMin]floatValue])  ;
					pos *= size;
					curLayer.position = CGPointMake( 00,pos-5 );
					
					[number setValue:[NSNumber numberWithBool:YES] forKey:@"found"];
				}
			}
			if(!foundANumber){
				[curLayer removeFromSuperlayer];
			}
		}
	}
	NSMutableDictionary * number;
	for(number in numbers){
		if([[number valueForKey:@"found"] isEqualToNumber:[NSNumber numberWithBool:NO]] ){
			float pos = ([[number valueForKey:@"value"] floatValue] - [[self yRangeMin]floatValue])  /   ( [[self yRangeMax]floatValue] - [[self yRangeMin]floatValue])  ;
			pos *= size;			
			CATextLayer * text = [CATextLayer layer];
			text.anchorPoint		= CGPointMake(0, 0);
			text.bounds			= CGRectMake(0, 0, 22, 10);			
			text.position			= CGPointMake( 00,pos-5 );
			text.string = [NSString stringWithFormat:@"%@",[number valueForKey:@"value"]];
			text.fontSize = 10;
			text.alignmentMode = kCAAlignmentRight;
			[leftValueArea addSublayer:text];
			
			CALayer * line = [CALayer layer];
			line.anchorPoint		= CGPointMake(0, 0);
			line.bounds			= CGRectMake(0, 0,2000, 1);
			line.position			= CGPointMake( 22,5 );
			line.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
			[text addSublayer:line];		}
	}*/
}

-(void) updateBottomScroller{
	//	NSLog(@"Update bottom");
	[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:@"animationDuration"];
	
	float min = ([[self xRangeMin] floatValue] - [[self xMin]floatValue])  /   ( [[self xMax]floatValue] - [[self xMin]floatValue])  ;
	min *= bottomScrollerArea.bounds.size.width;
	
	float max = ([[self xRangeMax] floatValue] - [[self xRangeMin]floatValue])  /   ( [[self xMax]floatValue] - [[self xMin]floatValue])  ;
	max *= bottomScrollerArea.bounds.size.width;
	
	bottomScrollerMarkedArea.position = CGPointMake(min,bottomScrollerMarkedArea.position.y);
	
	bottomScrollerMarkedArea.bounds = CGRectMake(0,0, max, bottomScrollerMarkedArea.bounds.size.height);
	
	/*
	
	NSMutableArray * numbers = [[NSMutableArray arrayWithCapacity:100] retain];
	double resolution = 1024; 
	float i = 0;
	float size = bottomValueArea.bounds.size.width;
	float delta = ([[self xRangeMax] floatValue] - [[self xRangeMin]floatValue]);
	while (size / ( delta / resolution) > 30 && resolution > 0.0001 ) {
		resolution /= 2.0;
		if(i++ > 200)
			break;
	}
	
	for( i=0 ; i<[[self xRangeMax] floatValue] ; i+= resolution){
		if([[self xRangeMin] floatValue] < i)
			[numbers addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:i],@"value",[NSNumber numberWithBool:NO],@"found",nil]];
	}
	
	
	CATextLayer * curLayer;
	for(i=0;i<[[bottomValueArea sublayers] count];i++){
		curLayer = [[bottomValueArea sublayers] objectAtIndex:i];
		if([[curLayer string] floatValue] > [[self xRangeMax] floatValue] || [[curLayer string] floatValue] < [[self xRangeMin] floatValue]){
			[curLayer setOpacity:0];
			[curLayer removeFromSuperlayer];
		} else {
			NSMutableDictionary * number;
			BOOL foundANumber = NO;
			for(number in numbers){
				if([[[number valueForKey:@"value"] stringValue] isEqualToString: [curLayer string]] ){
					if([[number valueForKey:@"found"] isEqualToNumber:[NSNumber numberWithBool:YES]]){
						[curLayer removeFromSuperlayer];	
					}
					foundANumber = YES;
					float pos = ([[number valueForKey:@"value"] floatValue] - [[self xRangeMin]floatValue])  /   ( [[self xRangeMax]floatValue] - [[self xRangeMin]floatValue])  ;
					pos *= size;
					curLayer.position = CGPointMake(pos-5 , 0);
					
					[number setValue:[NSNumber numberWithBool:YES] forKey:@"found"];
				}
			}
			if(!foundANumber){
				[curLayer setOpacity:0];
				[curLayer removeFromSuperlayer];
			}
		}
	}
	NSMutableDictionary * number;
	for(number in numbers){
		if([[number valueForKey:@"found"] isEqualToNumber:[NSNumber numberWithBool:NO]] ){
			float pos = ([[number valueForKey:@"value"] floatValue] - [[self xRangeMin]floatValue])  /   ( [[self xRangeMax]floatValue] - [[self xRangeMin]floatValue])  ;
			pos *= size;			
			CATextLayer * text = [CATextLayer layer];
			text.anchorPoint		= CGPointMake(0, 1);
			text.bounds			= CGRectMake(0, 0, 22, 10);			
			text.position			= CGPointMake(pos-5, 0 );
			text.string = [NSString stringWithFormat:@"%@",[number valueForKey:@"value"]];
			text.fontSize = 10;
			text.alignmentMode = kCAAlignmentRight;
			CATransform3D transform;
			transform = CATransform3DMakeRotation((90 * M_PI/180), 0,0,1);
			text.transform = transform;
			
			[bottomValueArea addSublayer:text];
			
			CALayer * line = [CALayer layer];
			line.anchorPoint		= CGPointMake(0, 0);
			line.bounds			= CGRectMake(0, 0,2000, 1);
			line.position			= CGPointMake( 22,5 );
			line.backgroundColor	= CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
			[text addSublayer:line];		
		}
	}*/
}




- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	/*if([(NSString*)context isEqualToString:@"updateLeftScroller"]){
		[self updateLeftScroller];
	}*/
	if([(NSString*)context isEqualToString:@"updateBottomScroller"]){
		[self updateBottomScroller];
	}
	
}

/*-(void) setYMax:(NSNumber *)n{
	//NSLog(@"SetYMax in view %@",n);
	BOOL rangeFollow = NO;
	if([yRangeMax floatValue] == [yMax floatValue]){
		rangeFollow = YES;
	}
	if(yMax != nil)
		[yMax release];
	yMax = [n retain];
	if([yMax floatValue] < [yRangeMax floatValue] || rangeFollow)
		[self setYRangeMax:yMax];
}
-(void) setYMin:(NSNumber *)n{
	//NSLog(@"SetYMin  in view %@",n);
	BOOL rangeFollow = NO;
	if([yRangeMin floatValue] == [yMin floatValue]){
		rangeFollow = YES;
	}
	if(yMin != nil)
		[yMin release];
	yMin = [n retain];	
	if([yMin floatValue] > [yRangeMin floatValue] || rangeFollow){
		float point = [yMin floatValue];
		if(point == 0)
			point = 0.00000000001;	
		[self setYRangeMin:[NSNumber numberWithFloat:point]];
		
	}
	
}*/

-(void) setXMax:(NSNumber *)n{
	//NSLog(@"SetXMax in view %@",n);
	BOOL rangeFollow = NO;
	if([xRangeMax floatValue] == [xMax floatValue]){
		rangeFollow = YES;
	}
	if(xMax != nil)
		[xMax release];
	xMax = [n retain];
	if([xMax floatValue] < [xRangeMax floatValue] || rangeFollow)
		[self setXRangeMax:xMax];
}
-(void) setXMin:(NSNumber *)n{
	//NSLog(@"SetXMin  in view %@",n);
	BOOL rangeFollow = NO;
	if([xRangeMin floatValue] == [xMin floatValue]){
		rangeFollow = YES;
	}
	if(xMin != nil)
		[xMin release];
	xMin = [n retain];	
	if([xMin floatValue] > [xRangeMin floatValue] || rangeFollow)
		[self setXRangeMin:xMin];
	
}
/*
 -(void) setYRangeMin:(NSNumber *)n{
 NSLog(@"SetYRangeMin  in view %@",n);
 [self willChangeValueForKey:@"yRangeMin"];
 if(yRangeMin != nil)
 [yRangeMin release];
 
 yRangeMin = [n retain];
 [self didChangeValueForKey:@"yRangeMin"];
 }*/

@end
