
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject
{
	BOOL noQuestionsAsked;
	BOOL isQuittingFromWindowClose;
	
}
@property (readwrite) BOOL noQuestionsAsked;

- (id) init;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app;
- (BOOL)windowShouldClose:(NSWindow *)sender;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)askToQuit:(NSWindow *) theWindow;
@end
