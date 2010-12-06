
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

typedef enum {
	NoMouseEvent = (1 << 0),
	LeftScrollerMouseTop = (1 << 1),
	LeftScrollerMouseBottom = (1 << 2),
	BottomScrollerMouseLeft = (1 << 3),
	BottomScrollerMouseRight = (1 << 4),

} MouseEvent;



@interface GraphDebugView : NSView {
	CALayer * rootLayer;
	CALayer* contentContainer;
	CALayer * leftScrollerArea;
	CALayer * bottomScrollerArea;
	CALayer * leftValueArea;
	CALayer * bottomValueArea;
	CALayer * leftScrollerMarkedArea;
	CALayer * bottomScrollerMarkedArea;
	MouseEvent  mouseEvent;
	
	CGPoint offsetDragPoint;
	NSNumber * yMax;
	NSNumber * yMin;
	NSNumber * yRangeMin;
	NSNumber * yRangeMax;

	NSNumber * xMax;
	NSNumber * xMin;
	NSNumber * xRangeMin;
	NSNumber * xRangeMax;
	
}
@property (retain) NSNumber * yMin;
@property (retain) NSNumber * yMax;
@property (retain) NSNumber * yRangeMin;
@property (retain) NSNumber * yRangeMax;
@property (retain) NSNumber * xMin;
@property (retain) NSNumber * xMax;
@property (retain) NSNumber * xRangeMin;
@property (retain) NSNumber * xRangeMax;

-(void) updateBottomScroller;
@end
