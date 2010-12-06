//
//  MainWindow.h
//  simpleExample
//
//  Created by Jonas Jongejan on 26/02/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainWindow : NSWindow {

	BOOL loadingState;
	NSView * topView;
	NSView * statusView;
	NSProgressIndicator * loadIndicator;
	NSTextField * loadText;

}

-(void) setFinishedLoading;
-(void) setLoadStatusText:(NSString*)text;
-(void)	setLoadPercentage:(float)percentage;


@end
