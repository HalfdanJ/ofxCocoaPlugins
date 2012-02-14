
#import "OutputViewStats.h"
#import "PluginOpenGLView.h"
#define numPoints 50

@implementation OutputViewStats
@synthesize fps;

-(id) initWithFrame:(NSRect)frameRect outputView:(PluginOpenGLView*)view{
	if(self = [super initWithFrame:frameRect]){
		
		historyData = [[NSMutableArray arrayWithCapacity:numPoints] retain];
		int i;
		for(i=0;i<numPoints;i++){
			[historyData addObject:[NSNumber numberWithInt:0]];
		}
		
		NSTextField * title = [[NSTextField alloc] initWithFrame:NSMakeRect(3, 0, frameRect.size.width-40, 20)];
		[title setAutoresizingMask:NSViewWidthSizable];
		[title setEditable:NO];
		[title setBordered:NO];
		[title setDrawsBackground:NO];
		[title setTextColor:[NSColor whiteColor]];
		[title setStringValue:[NSString stringWithFormat:@"Output %i fps:",[view viewNumber]]];
		
		NSTextField * fpsField = [[NSTextField alloc] initWithFrame:NSMakeRect(85, 0, frameRect.size.width-100, 20)];
		[fpsField setAutoresizingMask:NSViewWidthSizable];
		[fpsField setEditable:NO];
		[fpsField setBordered:NO];
		[fpsField setDrawsBackground:NO];
		[fpsField setTextColor:[[NSColor whiteColor] colorWithAlphaComponent:0.7]];
		[fpsField setStringValue:@"-" ];
		[fpsField bind:@"value" toObject:self withKeyPath:@"fps" options:nil];
		
		NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:1];
		[fpsField setFormatter:formatter];
		
		[self addSubview:title];
		[self addSubview:fpsField];
		
		
	}
	return self;
}


-(void) addHistory:(NSNumber*)_fps{
	if(_fps != nil){
		dispatch_async(dispatch_get_main_queue(), ^{			
			[historyData removeObjectAtIndex:0];
			[historyData addObject:_fps];
		});
	}
}
@end
