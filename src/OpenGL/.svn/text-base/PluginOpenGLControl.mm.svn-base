#include "GLee.h"

#import <OpenGL/OpenGL.h>
#import "PluginOpenGLControl.h"
extern ofAppBaseWindow * window;
#import "ofAppCocoaWindow.h"
@implementation PluginOpenGLControlView

-(BOOL) acceptsFirstResponder{
	return YES;
}
- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[((PluginOpenGLControl*)[self layer]) plugin] controlMousePressed:curPoint.x y:curPoint.y button:0];
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseX:curPoint.x]; 
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseY:curPoint.y];
}
- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[((PluginOpenGLControl*)[self layer]) plugin] controlMouseReleased:curPoint.x y:curPoint.y];
}
- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[((PluginOpenGLControl*)[self layer]) plugin] controlMouseDragged:curPoint.x y:curPoint.y button:0];
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseX: curPoint.x]; 
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseY: curPoint.y];	
}

-(void) scrollWheel:(NSEvent *)theEvent{
	[[((PluginOpenGLControl*)[self layer]) plugin] controlMouseScrolled:theEvent];
}

-(void) keyDown:(NSEvent *)theEvent{
	unsigned short keyCode = [theEvent keyCode];
	[[((PluginOpenGLControl*)[self layer]) plugin] controlKeyPressed:keyCode];	
	
	
	
}

@end



@implementation PluginOpenGLControl
@synthesize plugin;

-(id) init{
	if([super init]){
		drawingInformation = [[NSMutableDictionary dictionaryWithCapacity:6] retain];
	}
	return self;
	
}


- (BOOL)canDrawInCGLContext:(CGLContextObj)glContext 
                pixelFormat:(CGLPixelFormatObj)pixelFormat 
               forLayerTime:(CFTimeInterval)timeInterval 
                displayTime:(const CVTimeStamp *)timeStamp
{ 
	return YES;	
}



-(void)drawInCGLContext:(CGLContextObj)glContext pixelFormat:(CGLPixelFormatObj)pixelFormat forLayerTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp
{	
	NSAutoreleasePool * perFramePool = [[NSAutoreleasePool alloc] init];
	[[globalController openglLock] lock];
	
	CGLLockContext(glContext);
	CGLSetCurrentContext(glContext);
	
	glViewport(0, 0, [self frame].size.width , [self frame].size.height);
	if(![plugin setupCalled]){
		[plugin setup];
		[plugin setSetupCalled:YES];
	} else {
		
		glClear(GL_COLOR_BUFFER_BIT);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glTranslated(-1, 1, 0);
		glScaled(2.0/[self frame].size.width, -2.0/[self frame].size.height, 1);
		int tmpW = ((ofAppCocoaWindow*)window)->windowW;
		int tmpH = ((ofAppCocoaWindow*)window)->windowH;
		
		((ofAppCocoaWindow*)window)->windowW = [self frame].size.width;
		((ofAppCocoaWindow*)window)->windowH = [self frame].size.height;
		
		ofSetupScreen();
		
//		[plugin controlDraw:timeInterval displayTime:timeStamp];
		
		[drawingInformation setValue:[NSNumber numberWithDouble:timeInterval] forKey:@"timeInterval"];
//		[drawingInformation setValue:[NSNumber numberWithDouble:timeStamp->videoTime] forKey:@"outputTime.videoTime"];
		
		[plugin controlDraw:drawingInformation];
		
		
		((ofAppCocoaWindow*)window)->windowW = tmpW;
		((ofAppCocoaWindow*)window)->windowH = tmpH;
		
		glPopMatrix();
		
		
	}
	// Call super to finalize the drawing. By default all it does is call glFlush().
	[super drawInCGLContext:glContext pixelFormat:pixelFormat forLayerTime:timeInterval displayTime:timeStamp];
	
	CGLUnlockContext(glContext);
	
	[[globalController openglLock] unlock];
	
	[perFramePool release];
	
}


@end
