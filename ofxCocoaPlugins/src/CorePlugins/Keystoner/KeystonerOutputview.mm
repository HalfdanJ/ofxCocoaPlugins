#import "KeystonerOutputview.h"
#import "KeystoneSurface.h"
#import "OutputViewManager.h"

extern NSArray * arrayOfSurfaceNames;

@implementation KeystonerOutputview
@synthesize viewNumber, size, sizeRep, projectors, aspect, name;

-(id) initWithSurfaces:(NSArray*)surfaces{
	if([self init]){
		[self addObserver:self forKeyPath:@"size" options:nil context:@"size"];
		KeystoneProjector * proj =  [[[KeystoneProjector alloc] initWithSurfaces:surfaces viewNumber:viewNumber projectorNumber:0] autorelease];
		projectors = [[NSMutableArray arrayWithObject:proj] retain];
	}
	return self;
}


-(void) applySurface:(NSString*)surfaceName projectorNumber:(int)projectorNumber{
//	if([projectors count] > 1){
	glViewport((ofGetWidth()/[projectors count])*projectorNumber, 0, ofGetWidth()/[projectors count], ofGetHeight());
//	}
	if([projectors count] > projectorNumber){
		[[projectors objectAtIndex:projectorNumber] applySurface:surfaceName];
	}
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"size"]){
		[self setSizeRep:[NSString stringWithFormat:@"Outputview screen resolution: %dx%d", (int)size.width,(int) size.height]];
		[self setAspect:(size.width/ size.height)];
	}
}

-(void) setViewNumber:(int)v{
	[self willChangeValueForKey:@"viewNumber"];
	viewNumber = v;
	[self didChangeValueForKey:@"viewNumber"];
	
	PluginOpenGLView * view = [[[globalController viewManager] glViews] objectAtIndex:viewNumber];
	
	int numberOfScreens = 1;//round([view screenSize].width) / round([view screenSize].height*4/3);
	
	NSMutableArray * surfaces = [NSMutableArray array];
	KeystoneSurface * aSurface;
	for (aSurface in [[projectors lastObject] surfaces]) {
		[surfaces addObject:[aSurface name]];
	}
		
	[projectors removeAllObjects];

	for (int i = 0; i < numberOfScreens; i++) {
		KeystoneProjector * proj =  [[[KeystoneProjector alloc] initWithSurfaces:surfaces viewNumber:viewNumber projectorNumber:i] autorelease];
		[projectors addObject:proj];
	}
	
	if(view != nil){
		[self bind:@"size" toObject:view withKeyPath:@"screenSize" options:nil];
	} else {
		NSLog(@"view %i was null", v);
	}
}

@end
