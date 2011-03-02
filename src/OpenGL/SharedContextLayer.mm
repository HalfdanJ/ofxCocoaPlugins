#include "SharedContextLayer.h"

// reference to the first context created, used by all others
// as a shareContext reference

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

// 1)	[Optional] This message is sent prior to get a description of the pixel format that you need to render your content.
//		This pixel format should use the given display mask for the kCGLPFADisplayMask format attribute for optimal performance.
//**
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
	//	NSLog([NSString stringWithFormat:@"OpenGLDisplayMask%02X",openGLDisplayMask]);
		
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
				
		//NSLog(@"Shared Context Pixelformat Success");

		NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
		
		if(pixelFormat == nil) {
			
			//NSLog(@"Shared Context Pixelformat Fallback");

			NSOpenGLPixelFormatAttribute attrs[] =
			{
				NSOpenGLPFAWindow,
				NSOpenGLPFAAccelerated,
				NSOpenGLPFADoubleBuffer,
				(NSOpenGLPixelFormatAttribute)nil
			};
			
			NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
			
			if(pixelFormat == nil) {

			//NSLog(@"Shared Context Pixelformat not supported");
			return [super copyCGLPixelFormatForDisplayMask:mask];

			}
		}
		return (CGLPixelFormatObj) [pixelFormat CGLPixelFormatObj];

		[pixelFormat release];
		
	}
	
	//NSLog(@"Shared Context Pixelformat Defaulting");

	return [super copyCGLPixelFormatForDisplayMask:mask];
	
	
}

// 2)	[Optional] This message is sent prior to rendering to create a context to render to.
//		You would typically override this method if you needed to specify a share context to share OpenGL resources.
//		This is also an ideal location to do any initialization that is necessary for the context returned
-(CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat
{

//	NSLog(@"copyCGLContextForPixelFormat:");
	
	NSOpenGLContext * cnt = [globalController getSharedContext:pixelFormat];

	GLint	vblSynch = 0;
	[cnt setValues:&vblSynch forParameter:NSOpenGLCPSwapInterval];
	GLint	opacity = 0;
	[cnt setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
	
	[cnt retain];
	
	return (CGLContextObj)[cnt CGLContextObj];
	
}


-(void)releaseCGLContext:(CGLContextObj)glContext
{
	//NSLog(@"RELEASING Context");
    [super releaseCGLContext:glContext];
}


@end

