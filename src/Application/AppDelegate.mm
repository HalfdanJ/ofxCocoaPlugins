#import "AppDelegate.h"

@implementation AppDelegate
@synthesize noQuestionsAsked;

-(id) init {
	self = [super init];
	if (self) {
		noQuestionsAsked = NO;
	}
	return self;
}
-(void) dealloc{
	[super dealloc];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app {
	if(noQuestionsAsked){
		return NSTerminateNow;
	} else {
		[self askToQuit:[app mainWindow]];
		return NSTerminateLater;
	}
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
	[[NSApplication sharedApplication] terminate:sender];
	return NO;
}

- (void)askToQuit:(NSWindow *) theWindow {
    [theWindow makeKeyAndOrderFront:nil];
    NSBeginAlertSheet(NSLocalizedString(@"Do you want to Quit?", @"Title of alert panel which comes up when user chooses Quit"),
					  NSLocalizedString(@"Quit", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
					  NSLocalizedString(@"Cancel", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),
					  nil,
					  theWindow,
					  self,
					  @selector(willEndCloseSheet:returnCode:contextInfo:),
					  @selector(didEndCloseSheet:returnCode:contextInfo:),
					  nil,
					  NSLocalizedString(@"If you quit, the show gotta be over.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents.")
					  );
}

- (void)willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertAlternateReturn) {     /* "Don't quit" */
		[NSApp replyToApplicationShouldTerminate:NO];
    }
    if (returnCode == NSAlertDefaultReturn) {       /* "Quit" */
		// we need to quit here explicitly as other windows would otherwise keep the updates runing causing a illegal reference to this closed window.
		[NSApp replyToApplicationShouldTerminate:YES];
    } 
}

- (void)didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertAlternateReturn) {     /* "Don't quit" */
		[NSApp replyToApplicationShouldTerminate:NO];
    }
    if (returnCode == NSAlertDefaultReturn) {       /* "Quit" */
		// we need to quit here explicitly as other windows would otherwise keep the updates runing causing a illegal reference to this closed window.
		[NSApp replyToApplicationShouldTerminate:YES];
    } 	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}


@end
