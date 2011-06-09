#include "GLee.h"

#import <OpenGL/OpenGL.h>
#import "PluginOpenGLControl.h"
extern ofAppBaseWindow * window;
#import "ofAppCocoaWindow.h"


@implementation PluginOpenGLControlView
@synthesize controller, drawingInformation, plugin;

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
									  const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
									  CVOptionFlags *flagsOut, void *displayLinkContext)
{
	return [(PluginOpenGLView *)displayLinkContext getFrameForTime:((now->videoTime*1.0)/now->videoTimeScale) displayTime:outputTime];
}

-(void) awakeFromNib{
    //Create tracking view that is used when clicking in the plugin control view
	NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self frame] options:NSTrackingMouseEnteredAndExited | NSTrackingCursorUpdate | NSTrackingMouseMoved | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect owner:self userInfo:nil];
	[self addTrackingArea:area];
    CGDisplayCount maxDisplays = 32;
	CGDirectDisplayID activeDspys[32];
	CGDisplayErr theError;
	short i;
	CGDisplayCount dspyCnt = 0;
    
 	CGOpenGLDisplayMask openGLDisplayMask = 0;
	
	theError = CGGetActiveDisplayList(maxDisplays, activeDspys, &dspyCnt);
	
    for (i = 0; i < dspyCnt; i++) {
        openGLDisplayMask |= CGDisplayIDToOpenGLDisplayMask(activeDspys[i]);
    }
    NSOpenGLPixelFormatAttribute attrs[] =
	{
        
        NSOpenGLPFAScreenMask, openGLDisplayMask,
        NSOpenGLPFAWindow,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAPixelBuffer,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAMultisample,
        NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)4,
        NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)8,
        NSOpenGLPFADepthSize, 32,

        
        
		(NSOpenGLPixelFormatAttribute)nil
	};
	
	NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	[self setPixelFormat:pixelFormat];
    
    
    [self setOpenGLContext:[globalController getSharedContext:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]]];
	
	[self setDrawingInformation:[NSMutableDictionary dictionaryWithCapacity:6]];
    
    GLint zeroOpacity = 0;
	[[self openGLContext] setValues:&zeroOpacity forParameter:NSOpenGLCPSurfaceOpacity];
    
	backingWidth = 0;
	backingHeight = 0;
    
}

- (void)dealloc
{
	// it is critical to dispose of the display link
    if (displayLink) {
    	CVDisplayLinkStop(displayLink);
        CVDisplayLinkRelease(displayLink);
        displayLink = NULL;
    }
	
	[super dealloc];
}



// set up the OpenGL environs
- (void)prepareOpenGL
{
	GLint swapInterval = 1;
    
    // really nice perspective calculations
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    
    // turn on sphere map automatic texture coordinate generation
    // http://www.opengl.org/sdk/docs/man/xhtml/glTexGen.xml
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    
    // set up the GL contexts swap interval -- passing 1 means that
    // the buffers are swapped only during the vertical retrace of the monitor
    [[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	
	//[self setOpenGLContext:[controller getSharedContext:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]]];
	
	
    
	//glEnable(GL_MULTISAMPLE);
    
    
    // create display link for the main display
	if (NULL == displayLink) {
		
		CVDisplayLinkCreateWithCGDisplay(kCGDirectMainDisplay, &displayLink);
		if (NULL != displayLink) {
			// set the current display of a display link.
			CVDisplayLinkSetCurrentCGDisplay(displayLink, kCGDirectMainDisplay);
			
			// set the renderer output callback function
			CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
			
			// activates a display link.
			CVDisplayLinkStart(displayLink);
		} else {
			NSLog(@"ERROR could not create displayLink");
		}
	}
}



-(void) draw{
    
	[[controller openglLock] lock]; // prevent drawing from another thread if we're drawing already
	
    [[self openGLContext] makeCurrentContext];
    
	glViewport(0, 0, [self frame].size.width , [self frame].size.height);
	if(![plugin setupCalled]){
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT);
	} else {		
        
        glClearColor(0.0, 0.0, 0.0, 0.0);
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
		
		[plugin controlDraw:drawingInformation];
		
		((ofAppCocoaWindow*)window)->windowW = tmpW;
		((ofAppCocoaWindow*)window)->windowH = tmpH;
		
		glPopMatrix();		
	}
	
    [[self openGLContext] flushBuffer];
	
	[[controller openglLock] unlock];	
}

//
//----------------
//


- (void)reshape
{
	[[controller openglLock] lock];
	
	[[self openGLContext] makeCurrentContext];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	[[self openGLContext] update];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	[[controller openglLock] unlock];
}


//
//----------------
//

-(void) setBackingWidth:(int) width height:(int)height{
	GLint dim[2] = {width, height};
	CGLContextObj  ctx = (CGLContextObj) [[self openGLContext] CGLContextObj];
	CGLSetParameter(ctx, kCGLCPSurfaceBackingSize, dim);
	CGLEnable (ctx, kCGLCESurfaceBackingSize);	
	
	backingWidth = width;
	backingHeight = height;
	
}


//
//----------------
//


#pragma mark Display Link

- (CVReturn)getFrameForTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    if([self plugin] == [globalController selectedPlugin]){
        [drawingInformation setValue:[NSNumber numberWithDouble:timeInterval] forKey:@"timeInterval"];
        [self draw];
    }
    [pool release];
	
	return kCVReturnSuccess;
}


#pragma mark Mouse / Key Events

//
//------
//

-(BOOL) acceptsFirstResponder{
	return YES;
}

//
//------
//

-(void) mouseMoved:(NSEvent *)theEvent{
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseFlags:[theEvent modifierFlags]]; 
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseX: curPoint.x]; 
	[[((PluginOpenGLControl*)[self layer]) plugin] setControlMouseY: curPoint.y];	
	[[((PluginOpenGLControl*)[self layer]) plugin] controlMouseMoved:curPoint.x y:curPoint.y];
	
}

//
//------
//

- (void)mouseDown:(NSEvent *)theEvent {
	[[self window] makeFirstResponder:self];
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	
	[[self plugin] setControlMouseFlags:[theEvent modifierFlags]]; 
	[[self plugin] setControlMouseX:curPoint.x]; 
	[[self plugin] setControlMouseY:curPoint.y];
	[[self plugin] controlMousePressed:curPoint.x y:curPoint.y button:0];
}

//
//------
//

- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[self plugin] controlMouseReleased:curPoint.x y:curPoint.y];
}

//
//------
//

- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[self plugin] setControlMouseFlags:[theEvent modifierFlags]]; 
	[[self plugin] setControlMouseX: curPoint.x]; 
	[[self plugin] setControlMouseY: curPoint.y];	
	[[self plugin] controlMouseDragged:curPoint.x y:curPoint.y button:0];
    
}

//
//------
//

- (void)mouseExited:(NSEvent *)theEvent{
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	[[self plugin] controlMouseReleased:curPoint.x y:curPoint.y];
}

//
//------
//

-(void) scrollWheel:(NSEvent *)theEvent{
	[[self plugin] controlMouseScrolled:theEvent];
}

//
//------
//

-(void) keyDown:(NSEvent *)theEvent{
	unsigned short keyCode = [theEvent keyCode];
	[[self plugin] controlKeyPressed:keyCode];
}


@end



