
#include "Plugin.h"
#import "PluginOpenGLControl.h"


@implementation ofPlugin
@synthesize  name, enabled, view,  updateCpuTime,  drawCpuTime, initPluginCalled, setupCalled, properties, customProperties, powerMeterDictionary,  controlMouseX, controlMouseY, controlMouseFlags, icon;

-(id) init{
	if([super init]){
		setupCalled = NO;
		initPluginCalled = NO;
		canDisable = [NSNumber numberWithBool:YES];
		[self setProperties: [NSMutableDictionary dictionary]];
		[self setCustomProperties:[NSMutableDictionary dictionary]];
		
		powerMeterDictionary = [[NSMutableDictionary dictionary] retain];
		[powerMeterDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"show"];
//		icon = [[NSImage imageNamed:@"NSFollowLinkFreestandingTemplate"] retain];
				icon = [[NSImage imageNamed:@""] retain];
		//	plugin = self;
		
		[self addProperty:[BoolProperty boolPropertyWithDefaultvalue:0] named:@"Enabled"];
		[self bind:@"boolEnabled" toObject:properties withKeyPath:@"Enabled.value" options:nil];
		[self addObserver:self forKeyPath:@"boolEnabled" options:nil context:@"boolEnabled"];

	}	
	return self;
	
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"boolEnabled"]){
		[[properties objectForKey:@"Enabled"] setBoolValue:[self boolEnabled]];
	}
}



-(void) awakeFromNib{
	
	if(controlGlView != nil){
		//Setup the opengl view
		controlLayer = [PluginOpenGLControl layer];
		[((PluginOpenGLControl*)controlLayer) setPlugin:self];
		controlLayer.asynchronous = YES;
		controlLayer.needsDisplayOnBoundsChange = YES;
		[controlGlView setWantsLayer:YES];
		[controlGlView setLayer:controlLayer];	
		
	}
}

- (void) applicationWillTerminate: (NSNotification *)note{}

-(BOOL) willDraw:(NSMutableDictionary*)drawingInformation{
	return YES;
}
- (void) initPlugin {}

- (BOOL) loadPluginNibFile {
	if (![NSBundle loadNibNamed:[self name]  owner:self]){
		NSLog(@"Warning! Could not load the nib for %@ plugin",[self name]);
		return NO;
	}
	
	return YES;
	
}

- (void) setup{}
- (void) draw:(NSDictionary*)drawingInformation{}
- (void) update:(NSDictionary*)drawingInformation{}

- (void) controlSetup{};
- (void) controlDraw:(NSDictionary*)drawingInformation{};
- (void) controlMousePressed:(float) x y:(float)y button:(int)button{}
- (void) controlMouseReleased:(float) x y:(float)y{}
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{}
- (void) controlMouseScrolled:(NSEvent *)theEvent{}
- (void) controlKeyPressed:(int)key{}

- (BOOL) isEnabled{
	return [[self enabled] isEqualToNumber:[NSNumber numberWithBool:YES]];
}

- (BOOL) autoresizeControlview{
	return NO;	
}

-(void) setEnabled:(NSNumber *)n{
	[self willChangeValueForKey:@"enabled"];
	[self willChangeValueForKey:@"boolEnabled"];
	enabled = n;
	[self didChangeValueForKey:@"enabled"];
	[self didChangeValueForKey:@"boolEnabled"];
	
	[Prop(@"Enabled") setBoolValue:[n boolValue]];
}	

-(void) setBoolEnabled:(BOOL)b{
	[self willChangeValueForKey:@"enabled"];
	[self willChangeValueForKey:@"boolEnabled"];
	enabled = [[NSNumber numberWithBool:b] retain];
	[self didChangeValueForKey:@"boolEnabled"];
	[self didChangeValueForKey:@"enabled"];
}	

-(BOOL) boolEnabled{
	return [enabled boolValue];
}	

-(id) initWithCoder:(NSCoder *)coder{
	NSLog(@"Decode enabled: %i", [coder decodeBoolForKey:@"enabled"]);
}

-(void) encodeWithCoder:(NSCoder *)coder{
	NSLog(@"Encode plugin");
	[coder encodeBool:[enabled boolValue] forKey:@"enabled"];
}

-(void) setUpdateCpuUsage:(float)v{
	[self willChangeValueForKey:@"powerMeterDictionary"];
	[powerMeterDictionary setValue:[NSNumber numberWithFloat:v] forKey:@"cpu"];
	[self didChangeValueForKey:@"powerMeterDictionary"];
	
}

-(void) setDrawCpuUsage:(float)v{
	[self willChangeValueForKey:@"powerMeterDictionary"];
	[powerMeterDictionary setValue:[NSNumber numberWithFloat:v] forKey:@"gpu"];
	[self didChangeValueForKey:@"powerMeterDictionary"];
	
}

-(float) updateCpuUsage{
	return [[powerMeterDictionary valueForKey:@"cpu"] floatValue];
}
-(float) drawCpuUsage{
	return [[powerMeterDictionary valueForKey:@"gpu"] floatValue];
}

-(void) addProperty:(PluginProperty*)p named:(NSString*)_name{
	[p setName:_name];
	[properties setValue:p
				  forKey:_name];
	[p addObserver:self forKeyPath:@"value" options:nil context:@"property"];
	
	
}

@end

