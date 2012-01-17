
#import "ofAppCocoaWindow.h"
#import "ofMain.h"

#import "PluginOpenGLControlView.h"
#import "PluginManagerController.h"
#import "Plugin.h"
#import "OutputViewManager.h"

@implementation PluginOpenGLControlView
@synthesize controller, drawingInformation, plugin;

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
									  const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
									  CVOptionFlags *flagsOut, void *displayLinkContext)
{
	return [(PluginOpenGLControlView *)displayLinkContext getFrameForTime:((now->videoTime*1.0)/now->videoTimeScale) displayTime:outputTime];
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
        
        NSOpenGLPFAWindow,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 4,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 24,
        
//        NSOpenGLPFAAccelerated,

        
        
        
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
	
	//[self setOpenGLContext:[globalController getSharedContext:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]]];
	
	
    
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
    
    // cout << "   2 CONTROL DRAW WAIT " << [globalController openglLock] << endl;
    
    if([globalController lastViewDrawn] != 'c' || [[globalController viewManager] numberOutputViews] == 0){ // only draw if there's been an outputview before;
        
        [[globalController openglLock] lock]; // prevent drawing from another thread if we're drawing already
        
        // cout << "   2 CONTROL DRAW BEGIN " << [globalController openglLock] << endl;
        
        [[self openGLContext] makeCurrentContext];
        
        glViewport(0, 0, [self frame].size.width , [self frame].size.height);
        if(![plugin setupCalled]){
            glClearColor(0.0, 0.0, 0.0, 0.0);
            glClear(GL_COLOR_BUFFER_BIT);
            
            if([[globalController viewManager] numberOutputViews] == 0){
                [plugin setup];
                [plugin setSetupCalled:YES];
            }
        } else {		
            
            glClearColor(0.0, 0.0, 0.0, 0.0);
            glClear(GL_COLOR_BUFFER_BIT);
            glMatrixMode(GL_MODELVIEW);       
            
            glPushMatrix();
            glTranslated(-1, 1, 0);
            glScaled(2.0/[self frame].size.width, -2.0/[self frame].size.height, 1);
            
            ofPoint tmpSize = ofGetWindowSize();
            
            ofSetWindowShape([self frame].size.width, [self frame].size.height);
            
            ofSetupScreen();
            
            [plugin controlDraw:drawingInformation];
            
            ofSetWindowShape(tmpSize.x, tmpSize.y);
            
            glPopMatrix();		
        }
        
        [[self openGLContext] flushBuffer];
        
        // cout << "   2 CONTROL DRAW END " << [globalController openglLock] << endl;
        
        [globalController setLastViewDrawn:'c'];
        
        [[globalController openglLock] unlock];	
    }
}

//
//----------------
//


- (void)reshape
{
    [[globalController openglLock] lock];
    
    [[self openGLContext] makeCurrentContext];
    
    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    [[self openGLContext] update];
    
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    [[globalController openglLock] unlock];
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
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] setControlMouseFlags:[theEvent modifierFlags]]; 
    [[self plugin] setControlMouseX: curPoint.x]; 
    [[self plugin] setControlMouseY: curPoint.y];	
    [[self plugin] controlMouseMoved:curPoint.x y:curPoint.y];
    [[globalController openglLock] unlock];	
}

//
//------
//

- (void)mouseDown:(NSEvent *)theEvent {
    [[self window] makeFirstResponder:self];
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    curPoint.y = [self frame].size.height - curPoint.y;
    
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] setControlMouseFlags:[theEvent modifierFlags]]; 
    [[self plugin] setControlMouseX:curPoint.x]; 
    [[self plugin] setControlMouseY:curPoint.y];
    [[self plugin] controlMousePressed:curPoint.x y:curPoint.y button:0];
    [[globalController openglLock] unlock];	
}

//
//------
//

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    curPoint.y = [self frame].size.height - curPoint.y;
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] controlMouseReleased:curPoint.x y:curPoint.y];
    [[globalController openglLock] unlock];	
}

//
//------
//

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    curPoint.y = [self frame].size.height - curPoint.y;
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] setControlMouseFlags:[theEvent modifierFlags]]; 
    [[self plugin] setControlMouseX: curPoint.x]; 
    [[self plugin] setControlMouseY: curPoint.y];	
    [[self plugin] controlMouseDragged:curPoint.x y:curPoint.y button:0];
    [[globalController openglLock] unlock];	    
}

//
//------
//

- (void)mouseExited:(NSEvent *)theEvent{
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    curPoint.y = [self frame].size.height - curPoint.y;
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] controlMouseReleased:curPoint.x y:curPoint.y];
    [[globalController openglLock] unlock];	
}

//
//------
//

-(void) scrollWheel:(NSEvent *)theEvent{
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] controlMouseScrolled:theEvent];
    [[globalController openglLock] unlock];	
}

//
//------
//

-(void) keyDown:(NSEvent *)theEvent {
    ;
    unsigned short keyCode = [theEvent keyCode];
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] controlKeyPressed:keyCode modifier:[theEvent modifierFlags]];
    [[globalController openglLock] unlock];	
}

-(void) keyUp:(NSEvent *)theEvent{
    unsigned short keyCode = [theEvent keyCode];
    [[globalController openglLock] lock]; // prevent modifications while updating from DisplayLink
    [[self plugin] controlKeyReleased:keyCode modifier:[theEvent modifierFlags]];;
    [[globalController openglLock] unlock];	
}

@end



