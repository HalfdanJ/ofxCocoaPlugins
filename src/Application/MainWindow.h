//
//  MainWindow.h
//
//  Created by Jonas Jongejan on 26/02/10.
//

#import <Cocoa/Cocoa.h>


@interface MainWindow : NSWindow {
    
    //Loading stuff
	BOOL loadingState;
	NSView * topView;
	NSView * statusView;
	NSProgressIndicator * loadIndicator;
	NSTextField * loadText;

}

-(void) setFinishedLoading;
-(void) setLoadStatusText:(NSString*)text;
-(void)	setLoadPercentage:(float)percentage;

-(void) addPluginDetail:(NSString*)name text:(NSString*)text;
-(void) setPluginDetailNumber:(int)n to:(NSString*)s;


@end
