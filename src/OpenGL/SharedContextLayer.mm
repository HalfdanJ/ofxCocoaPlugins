#include "SharedContextLayer.h"


void bits_uint(unsigned int value)
{
	unsigned int bit;
	for ( bit = /* msb */(~0U >> 1) + 1; bit > 0; bit >>= 1 )
	{
		putchar(value & bit ? '1' : '0');
	}
	putchar('\n');
}



@implementation SharedContextLayer

-(CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask
{
	
	//NSLog(@"Setting up the Shared Context Pixelformat");
    
	CGDisplayCount maxDisplays = 32;
	CGDirectDisplayID activeDspys[32];
	CGDisplayErr theError;
	short i;
	CGDisplayCount dspyCnt = 0;
    
 	CGOpenGLDisplayMask openGLDisplayMask = 0;
	
	theError = CGGetActiveDisplayList(maxDisplays, activeDspys, &dspyCnt);
	
	if(!theError){
		for (i = 0; i < dspyCnt; i++) {
			openGLDisplayMask |= CGDisplayIDToOpenGLDisplayMask(activeDspys[i]);
		}
		
		bits_uint(openGLDisplayMask);		
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
			(NSOpenGLPixelFormatAttribute)nil
		};
        
		NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
		
		if(pixelFormat == nil) {
            NSOpenGLPixelFormatAttribute attrs[] =
			{
				NSOpenGLPFAWindow,
				NSOpenGLPFAAccelerated,
				NSOpenGLPFADoubleBuffer,
				(NSOpenGLPixelFormatAttribute)nil
			};
			NSLog(@"Creating simpler pixelformat in shared context");
            
			NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
			
			if(pixelFormat == nil) {
                
                NSLog(@"Shared Context Pixelformat not supported");
                return [super copyCGLPixelFormatForDisplayMask:mask];
                
			}
		}
		return (CGLPixelFormatObj) [pixelFormat CGLPixelFormatObj];
        
		[pixelFormat release];
		
	}
	return [super copyCGLPixelFormatForDisplayMask:mask];
}

//
//------
//


-(CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat
{
	NSOpenGLContext * cnt = [globalController getSharedContext:pixelFormat];
    
	GLint	vblSynch = 0;
	[cnt setValues:&vblSynch forParameter:NSOpenGLCPSwapInterval];
	GLint	opacity = 0;
	[cnt setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
	
	[cnt retain];
	
	return (CGLContextObj)[cnt CGLContextObj];
	
}


//
//------
//



-(void)releaseCGLContext:(CGLContextObj)glContext
{
    [super releaseCGLContext:glContext];
}


@end

