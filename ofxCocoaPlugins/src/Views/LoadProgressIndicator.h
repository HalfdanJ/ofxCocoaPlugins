
#import <Cocoa/Cocoa.h>


@interface LoadProgressIndicator : NSProgressIndicator {
	double doubleValue;
	NSView * progressView;
}

@property (readwrite) double doubleValue;

@end
