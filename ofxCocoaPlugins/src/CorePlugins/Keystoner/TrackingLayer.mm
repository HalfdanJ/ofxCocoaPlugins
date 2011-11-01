//
//  TrackingLayer.mm
//  loadnloop
//
//  Created by LoadNLoop on 25/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrackingLayer.h"
#import "Keystoner.h"
#import <QuartzCore/QuartzCore.h>

@implementation TrackingLayer
@synthesize scale, aspect, visible, handlePositionHolder, dataTarget, dragCorner;

-(void) setup{	
	dragCorner = -1;
	
	[self setLayoutManager:[CAConstraintLayoutManager layoutManager]];    
	self.borderColor = CGColorCreateGenericRGB(0.0f,0.0f,0.0f,0.5f);
	self.backgroundColor= CGColorCreateGenericRGB(0.0f,0.125f,0.2f,0.6f);
	self.cornerRadius = 5;
	self.borderWidth = 1.0;
	
	contentLayer = [CALayer layer];
	contentLayer.frame = self.frame;
	contentLayer.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
	
	contentLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	contentLayer.layoutManager=[CAConstraintLayoutManager layoutManager];
	
	[self addSublayer:contentLayer];
	
	outputViewLayer = [CALayer layer];
	outputViewLayer.frame = contentLayer.frame;
	outputViewLayer.bounds= contentLayer.frame; 
	outputViewLayer.backgroundColor = CGColorCreateGenericRGB(0.75f,1.0f,0.75f,0.1f);
	outputViewLayer.borderColor = CGColorCreateGenericRGB(1.0f,1.0f,1.0f,0.5f);
	outputViewLayer.borderWidth = 3.0;
	
	outputViewLayer.anchorPoint = CGPointMake(0, 0);
	outputViewLayer.position = CGPointMake(0, 0);
	outputViewLayer.layoutManager=[CAConstraintLayoutManager layoutManager];
	
	
	
	//		backgroundLayer.position         = CGPointMake( midX, midY );
	//	outputViewLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	
	constraintsArray = [[NSMutableArray array]retain];
	[constraintsArray addObject:[CAConstraint
								 constraintWithAttribute:kCAConstraintMaxY
								 relativeTo:@"superlayer"
								 attribute:kCAConstraintMaxY
								 offset:0]];
	[constraintsArray addObject:[CAConstraint
								 constraintWithAttribute:kCAConstraintHeight
								 relativeTo:@"superlayer"
								 attribute:kCAConstraintHeight
								 offset:0]];
	[constraintsArray addObject:[CAConstraint
								 constraintWithAttribute:kCAConstraintMidX
								 relativeTo:@"superlayer"
								 attribute:kCAConstraintMidX
								 offset:0]];
	[constraintsArray addObject:[CAConstraint
								 constraintWithAttribute:kCAConstraintWidth
								 relativeTo:@"superlayer"
								 attribute:kCAConstraintHeight
								 scale:0.5
								 offset:0]];
	
	[outputViewLayer setConstraints:constraintsArray];
	
	[contentLayer addSublayer:outputViewLayer];
	
	
	
	handles = [[NSMutableArray arrayWithCapacity:4] retain];
	int i;
	for (i=0; i<4; i++) {
		CALayer * layerHolder = [CALayer layer];
		[handles addObject:layerHolder];
		[outputViewLayer addSublayer:layerHolder];		
		
		layerHolder.layoutManager=[CAConstraintLayoutManager layoutManager];
		//layerHolder.backgroundColor =  CGColorCreateGenericRGB(0.0f,0.0f,1.0f,0.1f);
		layerHolder.frame = CGRectMake( layerHolder.superlayer.frame.origin.x,
									   layerHolder.superlayer.frame.origin.y, 
									   layerHolder.superlayer.frame.size.width, 
									   layerHolder.superlayer.frame.size.height);
		
		[layerHolder addConstraint:[CAConstraint
									constraintWithAttribute:kCAConstraintHeight
									relativeTo:@"superlayer"
									attribute:kCAConstraintHeight
									scale:1.0
									offset:0]];
		
		[layerHolder addConstraint:[CAConstraint
									constraintWithAttribute:kCAConstraintMinX
									relativeTo:@"superlayer"
									attribute:kCAConstraintMinX
									scale:1.0
									offset:0]];
		
		[layerHolder addConstraint:[CAConstraint
									constraintWithAttribute:kCAConstraintWidth
									relativeTo:@"superlayer"
									attribute:kCAConstraintHeight
									scale:1.0
									offset:0]];
		
		[layerHolder addConstraint:[CAConstraint
									constraintWithAttribute:kCAConstraintMinY
									relativeTo:@"superlayer"
									attribute:kCAConstraintMinY
									scale:1.0
									offset:0]];
		
		//layerHolder.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable ;
		
		
		CALayer * layer = [CALayer layer];
		[layerHolder addSublayer:layer];	
		layer.name = [NSString stringWithFormat:@"%i",i];

		CGColorRef color =  CGColorCreateGenericRGB(1.0f,1.0f,0.0f,0.33f); 
		layer.backgroundColor = color;
		CFRelease(color);
		
		layer.borderColor = CGColorCreateGenericRGB(1.0f,1.0f,0.0f,0.7f);
		layer.borderWidth = 1.0;
		layer.cornerRadius = 10.0;
		layer.frame = CGRectMake(layer.superlayer.bounds.size.width-10,layer.superlayer.bounds.size.height-10, 20, 20);
		layer.autoresizingMask = kCALayerMinXMargin | kCALayerMinYMargin;
		
		
	}
		
	[self layoutSublayers];
	[self layoutIfNeeded];
	
	[self addObserver:self forKeyPath:@"handlePositionHolder" options:nil context:@"corners"];
	
}

-(void)setScale:(float)_scale{
	[self willChangeValueForKey:@"scale"];
	scale = _scale;
	[contentLayer setValue:[NSNumber numberWithFloat:scale] forKeyPath:@"transform.scale.x"];
	[contentLayer setValue:[NSNumber numberWithFloat:scale] forKeyPath:@"transform.scale.y"];
	
	[self didChangeValueForKey:@"scale"];
}

-(void) scrollWheel:(NSEvent *)theEvent{
	
	[self setScale:MAX(MIN([self scale]+[theEvent deltaY]*0.03, 10),0.1)];
}

-(void) setAspect:(float)v{
	
	[self willChangeValueForKey:@"aspect"];	
	v = 4.0/3;
	aspect = v;
	[constraintsArray removeLastObject];
	[constraintsArray addObject:[CAConstraint
								 constraintWithAttribute:kCAConstraintWidth
								 relativeTo:@"superlayer"
								 attribute:kCAConstraintHeight
								 scale:v
								 offset:0]];
	[outputViewLayer setConstraints:constraintsArray];
	
	[self didChangeValueForKey:@"aspect"];
}

-(void) setVisible:(BOOL)v{
	[self willChangeValueForKey:@"visible"];	
	visible = v;
	[self didChangeValueForKey:@"visible"];
	[contentLayer setHidden:!v];
}

/*-(void) setHandlePositionHolder:(NSArray *)a{
 [self willChangeValueForKey:@"handlePositionHolder"];
 if(handlePositionHolder != nil)
 [handlePositionHolder release];
 handlePositionHolder = [a retain];
 [self didChangeValueForKey:@"handlePositionHolder"];
 
 
 }*/


-(void) keyDown:(NSEvent *)theEvent{
	NSLog(@"%@",theEvent);
}

-(void) mouseDragged:(CGPoint)cgLocation{
	CGPoint cgLocationView = [self convertPoint:cgLocation toLayer:outputViewLayer];
	if(dragCorner != -1){
		NSMutableArray * handleHolder = [self handlePositionHolder] ;
		//	NSLog(@"Check handle %@",handleHolder);
		NSMutableDictionary * dict = [handleHolder objectAtIndex:dragCorner];
		float x = [[dict objectForKey:@"x"] floatValue] +  (cgLocationView.x-lastMousePos.x)/outputViewLayer.bounds.size.width; 

		float y = [[dict objectForKey:@"y"] floatValue] + (cgLocationView.y-lastMousePos.y)/outputViewLayer.bounds.size.height;

		[dict setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
		[dict setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
		[self setHandlePositionHolder:handleHolder];
	}
	
	lastMousePos = cgLocationView;
	
}	

-(void) mouseDown:(CGPoint)cgLocation{
	CGPoint cgLocationView = [self convertPoint:cgLocation toLayer:outputViewLayer];

	//	CALayer *layer = [self hitTest:cgLocation];
	
	CALayer *_layer = nil;
	for(int i=0;i<[handlePositionHolder count];i++){
		NSMutableDictionary * dict = [handlePositionHolder objectAtIndex:i];
		CGColorRef color =  CGColorCreateGenericRGB(1.0f,1.0f,0.0f,0.33f); 
		((CALayer*)[[[handles objectAtIndex:i] sublayers] objectAtIndex:0]).backgroundColor = color;
		CFRelease(color);
		
		if(fabs([[dict objectForKey:@"x"] floatValue] * outputViewLayer.bounds.size.width - cgLocationView.x) < 40 &&
		   fabs([[dict objectForKey:@"y"] floatValue] * outputViewLayer.bounds.size.height - cgLocationView.y) < 40  ){
			
			_layer = [[[handles objectAtIndex:i] sublayers] objectAtIndex:0];
		}
	}
	
	if(_layer != nil && _layer.name != nil){
		dragCorner = [_layer.name intValue];
		CGColorRef color =  CGColorCreateGenericRGB(1.0f,0.0f,0.0f,0.33f); 
		_layer.backgroundColor = color;
		CFRelease(color);
	
	} else {
		dragCorner = -1;	
		
	}
	lastMousePos = cgLocationView;
	
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"corners"]){
		[dataTarget setCornerArray:[self handlePositionHolder]];
		
		NSMutableDictionary * dict;
		for(dict in [self handlePositionHolder]){
			CALayer * handle = [handles objectAtIndex:[[dict objectForKey:@"num"] intValue]];
			NSMutableArray * arr = [NSMutableArray arrayWithCapacity:4];
			
			[arr addObject:[CAConstraint
							constraintWithAttribute:kCAConstraintHeight
							relativeTo:@"superlayer"
							attribute:kCAConstraintHeight
							scale:[[dict objectForKey:@"y"] floatValue]
							offset:0]];
			
			[arr addObject:[CAConstraint
							constraintWithAttribute:kCAConstraintMinX
							relativeTo:@"superlayer"
							attribute:kCAConstraintMinX
							scale:1.0
							offset:outputViewLayer.bounds.size.width * MIN(0,[[dict objectForKey:@"x"] floatValue])]];
			
			[arr addObject:[CAConstraint
							constraintWithAttribute:kCAConstraintWidth
							relativeTo:@"superlayer"
							attribute:kCAConstraintWidth
							scale:MAX(0,[[dict objectForKey:@"x"] floatValue])
							offset:0]];
			
			[arr addObject:[CAConstraint
							constraintWithAttribute:kCAConstraintMinY
							relativeTo:@"superlayer"
							attribute:kCAConstraintMinY
							scale:1.0
							offset:outputViewLayer.bounds.size.height * MIN(0,[[dict objectForKey:@"y"] floatValue])]];
			
			[handle setConstraints:arr];
		}
	}
}



@end