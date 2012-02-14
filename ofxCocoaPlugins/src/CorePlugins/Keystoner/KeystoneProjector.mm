
#import "KeystoneProjector.h"
#import "Keystoner.h"
#import "KeystoneSurface.h"

@implementation KeystoneProjector
@synthesize surfaces,viewNumber, projectorNumber;

-(void) dealloc{
	[surfaces release];
	[super dealloc];
}

-(id) initWithSurfaces:(NSArray*)_surfaces viewNumber:(int)_viewNumber projectorNumber: (int)_projectorNumber{
	if(self = [self init]){

		viewNumber = _viewNumber;
		projectorNumber = _projectorNumber;
		
		surfaces = [[NSMutableArray array] retain];
		NSString * surfaceName;
		for(surfaceName in _surfaces){
			KeystoneSurface * newSurface = [[KeystoneSurface alloc] init];
			[newSurface setName:surfaceName];
			[newSurface setViewNumber:viewNumber];
			[newSurface setProjectorNumber:projectorNumber];
			[surfaces addObject:newSurface];
		}
	}
	return self;
}
-(void) applySurface:(NSString*)surfaceName{
	for(KeystoneSurface * surface in surfaces){
		if([[surface name] isEqualToString:surfaceName]){
			[surface apply];
		}
	}
}
-(void) setViewNumber:(int)v{
	[self willChangeValueForKey:@"viewNumber"];
	viewNumber = v;
	[self didChangeValueForKey:@"viewNumber"];
	
	for(KeystoneSurface * surf in surfaces){
		[surf setViewNumber:v];
	}
	
}

-(void) setProjectorNumber:(int)v{
	[self willChangeValueForKey:@"projectorNumber"];
	projectorNumber = v;
	[self didChangeValueForKey:@"projectorNumber"];
	
	for(KeystoneSurface * surf in surfaces){
		[surf setProjectorNumber:v];
	}
	
}

-(NSString*) viewName{
	return [[[GetPlugin(Keystoner) outputViews] objectAtIndex:viewNumber] name];
}

@end
