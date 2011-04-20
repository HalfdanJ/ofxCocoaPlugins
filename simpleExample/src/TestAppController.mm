//
//  TestAppController.m
//
//  Created by Jonas Jongejan on 03/11/09.
//

#import "TestAppController.h"
#include "PluginIncludes.h"
#include "testApp.h"
#include "ofAppCocoaWindow.h"

extern testApp * OFSAptr;
extern ofAppBaseWindow * window;

@implementation TestAppController

-(id) init{
	if([super init]){
		return self;
	}
}


-(void) setupApp{
	[pluginManagerController setNumberOutputViews:2];	
}


-(void) awakeFromNib {
	NSLog(@"Awake test app controller from nib");
	
	
	baseApp = OFSAptr;
	cocoaWindow = window;	
	((ofAppCocoaWindow*)cocoaWindow)->windowController = self;
	
	ofSetBackgroundAuto(false);
	
}

-(void) setupPlugins{
	NSLog(@"Setup plugins");
	
	[pluginManagerController addHeader:@"My Plugins"];
	[pluginManagerController addPlugin:[[SamplePlugin alloc] init]];
	[pluginManagerController addPlugin:[[SamplePlugin2 alloc] init]];

	[pluginManagerController addHeader:@"Core Plugins"];
	[pluginManagerController addPlugin:[[Keystoner alloc] initWithSurfaces:[NSArray arrayWithObjects:@"Wall", @"Floor", nil]]];

	
	//[pluginManagerController addPlugin:[[Cameras alloc] initWithNumberCameras:1]];
	
	/*[pluginManagerController addHeader:@"Input"];
	 [pluginManagerController addPlugin:[[Cameras alloc] initWithMidiChannel:1]];
	 [pluginManagerController addPlugin:[[Lenses alloc] init]];
	 [pluginManagerController addPlugin:[[Midi alloc] init]];
	 
	 [pluginManagerController addHeader:@"Calculation"];
	 [pluginManagerController addPlugin:[[Tracking alloc] initWithMidiChannel:1]];
	 [pluginManagerController addPlugin:[[ProjectionSurfaces alloc] init]];
	 [pluginManagerController addPlugin:[[CameraCalibration alloc] init]];
	 
	 [pluginManagerController addHeader:@"Output"];
	 //	[pluginManagerController addPlugin:[[_ExampleOutput alloc] init]];
	 [pluginManagerController addPlugin:[[Players alloc] initWithMidiChannel:2]];
	 
	 //	[pluginManagerController addPlugin:[[DanceSteps alloc] initWithMidiChannel:3]];
	 //[pluginManagerController addPlugin:[[ParallelWorld alloc] init]];
	 [pluginManagerController addPlugin:[[Lines alloc] initWithMidiChannel:4]];
	 [pluginManagerController addPlugin:[[Stregkode alloc] initWithMidiChannel:5]];
	 [pluginManagerController addPlugin:[[Lemmings alloc] initWithMidiChannel:6]];
	 [pluginManagerController addPlugin:[[GTA alloc] initWithMidiChannel:7]];
	 [pluginManagerController addPlugin:[[GrowingShadow alloc] initWithMidiChannel:9]];
	 
	 [pluginManagerController addPlugin:[[Ulykke alloc] initWithMidiChannel:10]];
	 [pluginManagerController addPlugin:[[Arkade alloc] initWithMidiChannel:11]];
	 [pluginManagerController addPlugin:[[Jail alloc] initWithMidiChannel:12]];
	 [pluginManagerController addPlugin:[[Combat alloc] initWithMidiChannel:13]];
	 [pluginManagerController addPlugin:[[Strategi alloc] initWithMidiChannel:8]];
	 
	 
	 [pluginManagerController addPlugin:[[DMXOutput alloc] initWithMidiChannel:15]];
	 [pluginManagerController addPlugin:[[HardwareBox alloc] initWithMidiChannel:1]];
	 
	 //	[pluginManagerController addPlugin:[[_ExampleOutputAgain alloc] init]];
	 */
}

-(void) showMainWindow{
	NSLog(@"--- show main window ---\n");	
	/*[[[NSApplication sharedApplication] mainWindow] setAlphaValue:0.0];
	 [[[NSApplication sharedApplication] mainWindow] orderFront:self];
	 
	 // firstView, secondView are outlets
	 NSViewAnimation *theAnim;
	 NSMutableDictionary* animWindowDict;
	 
	 // Create the attributes dictionary for the second view.
	 animWindowDict = [NSMutableDictionary dictionaryWithCapacity:2];
	 
	 [animWindowDict setObject:self forKey:NSViewAnimationTargetKey];
	 
	 [animWindowDict setObject:NSViewAnimationFadeInEffect
	 forKey:NSViewAnimationEffectKey];
	 
	 // Create the view animation object.
	 theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
	 arrayWithObjects:animWindowDict, nil]];
	 
	 // Set some additional attributes for the animation.
	 [theAnim setDuration:0.25];
	 [theAnim setAnimationCurve:NSAnimationEaseInOut];
	 
	 [theAnim startAnimation];
	 
	 // The animation has finished, so go ahead and release it.
	 [theAnim release];
	 
	 [[[NSApplication sharedApplication] mainWindow] makeKeyAndOrderFront:nil];
	 
	 */
}

@end
