
#import <Cocoa/Cocoa.h>


@interface LoadProgressIndicator : NSView {
	double doubleValue;
	NSView * progressView;
}

@property (readwrite) double doubleValue;

@end
