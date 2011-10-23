//Based on QTCoreVideo101 example by apple

#import "ofAppCocoaWindow.h"
#import "ofMain.h"

#import "PluginOpenGLView.h"

#import "PluginManagerController.h"
#import "OutputViewStats.h"

static ofAppCocoaWindow * window;
//
//----------------
//


@interface PluginOpenGLView (InternalMethods)

- (CVReturn)getFrameForTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;
- (void)drawFrame:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;

@end

//
//----------------
//

@implementation PluginOpenGLView
@synthesize controller, viewManager, viewWidth, viewHeight, viewNumber, displayId, drawingInformation, screenSize, inFullscreen;	



static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
									  const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
									  CVOptionFlags *flagsOut, void *displayLinkContext)
{
	CVReturn result = [(PluginOpenGLView *)displayLinkContext getFrameForTime:((now->videoTime*1.0)/now->videoTimeScale) displayTime:outputTime];
   
	return result;
}


//
//----------------
//

- (void)awakeFromNib
{
	[self setOpenGLContext:[controller getSharedContext:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]]];
	
    //Create a new statsview (containing framerate)
	statsView = [[[OutputViewStats alloc]initWithFrame:NSMakeRect(10, [[controller statsAreaView] frame].size.height - 40- 30*[self viewNumber],  [[controller statsAreaView] frame].size.width-20, 30) outputView:self] retain];
	[statsView setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable];
	[[controller statsAreaView] addSubview:statsView];
	
    //Create a timer for updating the statsview
	NSTimer * timer = [NSTimer timerWithTimeInterval:(120.0f/60.0f) target:self selector:@selector(updateStats) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize
	
    //Create a empty drawing information dictionary (is going to contain frame information send to the plugins when drawing)
	[self setDrawingInformation:[NSMutableDictionary dictionaryWithCapacity:6]];
	
	backingWidth = 0;
	backingHeight = 0;
}


//
//----------------
//


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

//
//----------------
// Set up the OpenGL environs


- (void)prepareOpenGL
{
	GLint swapInterval = 1;
    
    // really nice perspective calculations
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    
    // turn on sphere map automatic texture coordinate generation
    // http://www.opengl.org/sdk/docs/man/xhtml/glTexGen.xml
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    
    glEnable(GL_MULTISAMPLE);
    
    // set up the GL contexts swap interval -- passing 1 means that
    // the buffers are swapped only during the vertical retrace of the monitor
    [[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	
	
	NSOpenGLPixelFormatAttribute attrs[] =
	{
        NSOpenGLPFASupersample,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 4,
        
        //        
        ////		NSOpenGLPFAWindow,
        ////		NSOpenGLPFAAccelerated,
        ////		NSOpenGLPFADoubleBuffer,
        //		NSOpenGLPFAPixelBuffer,
        //		NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)4,
        //		NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)4,
        //        
        //        kCGLPFAColorSize, 24,
        //		kCGLPFADepthSize, 16,
        //        
        //        NSOpenGLPFADoubleBuffer,
        //        NSOpenGLPFAAccelerated,
        //        NSOpenGLPFADepthSize, 24,
        //        NSOpenGLPFAStencilSize, 8,
        //        NSOpenGLPFASingleRenderer,
        //        NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
        //        NSOpenGLPFANoRecovery,
        
        
        kCGLPFAAccelerated,
		kCGLPFANoRecovery,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
        
        
        
		(NSOpenGLPixelFormatAttribute)nil
	};
	
	NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];	
	[self setPixelFormat:pixelFormat];
	
    
    
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

//
//----------------
// Called every time the window changes size

- (void)reshape
{
	[[controller openglLock] lock];
	
	[[self openGLContext] makeCurrentContext];
	
	// remember to lock the context before we touch it since display link is threaded
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	// let the context know we've changed size
	[[self openGLContext] update];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	NSSize	viewBounds = [self bounds].size;
	
	viewWidth = viewBounds.width;
	viewHeight = viewBounds.height;
    
	[[controller openglLock] unlock];
}


//
//----------------
// DrawRect is called in every frame. Here is the actual drawing done
//

-(void) drawRect:(NSRect)dirtyRect{
    // prevent drawing from another thread if we're drawing already
	[[controller openglLock] lock]; 
	
	// make the GL context the current context
	[[self openGLContext] makeCurrentContext];
    
	// draw here	
	if([controller isPluginsInited]){	
		if(![controller isSetupCalled] || [controller willDraw:drawingInformation]){
            if(![controller isSetupCalled]){             
                //Create the openframeworks context
//                window = new ofAppCocoaWindow();
                ofSetupOpenGL(ofPtr<ofAppBaseWindow>(new ofAppCocoaWindow()), 0, 0, 0);
                ofSetBackgroundAuto(false);
            }
            

            
            //Tell openframeworks the size of the window
            ofSetWindowShape([self frame].size.width, [self frame].size.height);
            
            //Reset the drawingarea
            ofBackground(0, 0, 0);
            
			glMatrixMode(GL_TEXTURE);
			glLoadIdentity();
			
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			
			glTranslated(-1, 1, 0.0);			
			glScaled(2, -2, 1.0);
			
			
			if(backingWidth != 0 && backingHeight != 0){				
				glTranslated(0, 1, 0);
				glScaled((float) backingWidth / [self frame].size.width,(float) backingHeight / [self frame].size.height, 1.0);	
				glTranslated(0, -1, 0);
			}			
			

			glPushMatrix();
			
			//Call the setup code if its the first time
            if(![controller isSetupCalled]){
				[controller callSetup];
			}	
            
            //The drawing from the plugins 
			[controller callDraw:drawingInformation];
			
			glPopMatrix();

            //Flush the buffer to draw to screen
			glFlush();
            //[[self openGLContext] flushBuffer];
            
            //Add the framerate to the statsview
			[statsView addHistory:[drawingInformation valueForKey:@"fps"]];
		}
	} else {
		glClearColor(0,0,0,255);
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      	glFlush();
	}	
	
	[[controller openglLock] unlock];	
}


//
//----------------
//


#pragma mark Display Link
// getFrameForTime is called from the Display Link callback when it's time for us to check to see
// if we have a frame available to render -- if we do, draw -- if not, just task the Visual Context and split
- (CVReturn)getFrameForTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    //Create the drawingInformation dictionary with all the timing information
	[drawingInformation setValue:[NSNumber numberWithDouble:timeInterval] forKey:@"timeInterval"];
	[drawingInformation setValue:[NSNumber numberWithDouble:outputTime->videoTime] forKey:@"outputTime.videoTime"];
	[drawingInformation setValue:[NSNumber numberWithInt:viewNumber] forKey:@"outputViewNumber"];
	dispatch_async(dispatch_get_main_queue(), ^{
		[drawingInformation setValue:[[self window] title] forKey:@"outputViewTitle"];
	});	
	NSValue *v = [NSValue value:&outputTime withObjCType:@encode(CVTimeStamp*)];
	[drawingInformation setValue:v forKey:@"outputTime"];	
	
	[self drawRect:NSZeroRect];
	
    [pool release];
	
	return kCVReturnSuccess;
}


//
//----------------
// The little FPS counter. Updated by a NSTimer
//

-(void)updateStats{
	[statsView setFps:[drawingInformation valueForKey:@"fps"]];
	[statsView reloadGraph];
}


//
//----------------
//


- (void) updateDisplayIDWithWindow:(NSWindow*)window
{			
    CGDirectDisplayID displayID = (CGDirectDisplayID)[[[[window screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
	
    if  ((displayID != 0) && (viewDisplayID != displayID) && [[self window] screen] == [window screen]) {		
        if (NULL != displayLink) {
			NSLog(@"New DisplayID %i on outputview %i",displayID,viewNumber);
            CVDisplayLinkSetCurrentCGDisplay(displayLink, displayID);
        }
        viewDisplayID = displayID;
    }	
}


//
//----------------
//

- (void)windowChangedScreen:(NSNotification*)inNotification
{
    
    NSWindow *window = [inNotification object];
	[self updateDisplayIDWithWindow:window];
}


//
//----------------
//


-(void) setDisplayNumber:(id)sender{
	CGDisplayCount		dspCount = 0;
	CGDirectDisplayID *displays = nil;
	dspCount = (CGDisplayCount) [viewManager getDisplayList:&displays];
	
	if([sender indexOfSelectedItem] == 0){
		displayId = nil;
	} else {
		displayId = displays[[sender indexOfSelectedItem]-1];
	}
	
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:[NSNumber numberWithInt:displayId] forKey:[NSString stringWithFormat:@"DisplayIdForView%i",viewNumber]];
	
	if(displayId != 0){
		[self setScreenSize:NSMakeSize(CGDisplayPixelsWide(displayId), CGDisplayPixelsHigh(displayId))];
	} else {
		[self setScreenSize:NSMakeSize(640,480)];		
	}
	
	[[self window] setMinSize:NSMakeSize(screenSize.width/5, 40+(screenSize.height/5))];
	
	NSRect windowRect = [[self window] frame];
	
	windowRect.size.height = fmax((screenSize.height/5)+40, windowRect.size.height);
	
	windowRect.size.width = (windowRect.size.height-40)*(screenSize.width/screenSize.height);
	
	[[self window] setFrame:windowRect display:YES animate:YES];
	
	free(displays);
	NSLog(@"		Select display %ld for outputView %i",[sender indexOfSelectedItem]-1, viewNumber);
}


//
//----------------
//

#pragma mark MouseEvents 
-(void) mouseDown:(NSEvent *)theEvent{
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	curPoint.y /= [self frame].size.height;
	curPoint.x /= [self frame].size.width;
	[controller mouseDownPoint:curPoint];	
}


//
//----------------
//


-(void) mouseUp:(NSEvent *)theEvent{
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	curPoint.y /= [self frame].size.height;
	curPoint.x /= [self frame].size.width;	
	[controller mouseUpPoint:curPoint];	
}


//
//----------------
//


-(void) mouseDragged:(NSEvent *)theEvent{
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	curPoint.y = [self frame].size.height - curPoint.y;
	curPoint.y /= [self frame].size.height;
	curPoint.x /= [self frame].size.width;
	[controller mouseDraggedPoint:curPoint];
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




@end