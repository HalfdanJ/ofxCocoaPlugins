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
	NSImageView * iconView;
	
	NSMutableArray * details;

}

-(void) setFinishedLoading;
-(void) setLoadStatusText:(NSString*)text;
-(void)	setLoadPercentage:(float)percentage;

-(void) addPluginDetail:(NSString*)name text:(NSString*)text;
-(void) setPluginDetailNumber:(int)n to:(NSString*)s;


@end
