
#include "Plugin.h"
#import "PluginOpenGLControlView.h"
#import "PluginManagerController.h"
#import "QLabController.h"


@implementation ofPlugin
@synthesize  name, enabled, view,  updateCpuTime,  drawCpuTime, initPluginCalled, setupCalled, properties, customProperties, powerMeterDictionary,  controlMouseX, controlMouseY, controlMouseFlags, icon, midiChannel, controlGlView;

-(id) init{
	if([super init]){
		[self setName:NSStringFromClass([self class])];
		
		
		setupCalled = NO;
		initPluginCalled = NO;
		midiChannel = nil;
		canDisable = [NSNumber numberWithBool:YES];
		[self setProperties: [NSMutableDictionary dictionary]];
		[self setCustomProperties:[NSMutableDictionary dictionary]];
		
		powerMeterDictionary = [[NSMutableDictionary dictionary] retain];
		[powerMeterDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"show"];
		icon = [[NSImage imageNamed:@""] retain];
		
		[self addProperty:[BoolProperty boolPropertyWithDefaultvalue:0] named:@"Enabled"];
		[self bind:@"boolEnabled" toObject:properties withKeyPath:@"Enabled.value" options:nil];
		[self addObserver:self forKeyPath:@"boolEnabled" options:nil context:@"boolEnabled"];
        [self addObserver:self forKeyPath:@"customProperties" options:nil context:@"customProperties"];
        
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
        controlGlView.controller = globalController;
	}
}


- (void) applicationWillTerminate: (NSNotification *)note{}

- (BOOL) loadPluginNibFile {
	if (![NSBundle loadNibNamed:[self name]  owner:self]){
		NSLog(@"Warning! Could not load the nib for %@ plugin",[self name]);
		return NO;
	}
	
	return YES;	
}

- (void) initPlugin {}
- (void) setup{}
- (BOOL) willDraw:(NSMutableDictionary*)drawingInformation{ return YES; }
- (void) draw:(NSDictionary*)drawingInformation{}
- (void) update:(NSDictionary*)drawingInformation{}

- (void) controlSetup{};
- (void) controlDraw:(NSDictionary*)drawingInformation{};
- (void) controlMouseMoved:(float) x y:(float)y{};
- (void) controlMousePressed:(float) x y:(float)y button:(int)button{}
- (void) controlMouseReleased:(float) x y:(float)y{}
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{}
- (void) controlMouseScrolled:(NSEvent *)theEvent{}
- (void) controlKeyPressed:(int)key modifier:(int)modifier{}
- (void) controlKeyReleased:(int)key modifier:(int)modifier{}

- (void) customPropertiesLoaded{}
- (void) willSave{}

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

/*-(id) initWithCoder:(NSCoder *)coder{
 NSLog(@"Decode enabled: %i", [coder decodeBoolForKey:@"enabled"]);
 }
 
 -(void) encodeWithCoder:(NSCoder *)coder{
 NSLog(@"Encode plugin");
 [coder encodeBool:[enabled boolValue] forKey:@"enabled"];
 }*/

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
	[p setPluginName:[self name]];
	[properties setValue:p forKey:_name];
	[p addObserver:self forKeyPath:@"value" options:nil context:@"property"];
	
	//Set global midiChannel if assigned
	if(midiChannel != nil){
		[p setMidiChannel:midiChannel];
	}	
}

-(NumberProperty*) addPropF:(NSString*)_name {
    NumberProperty * p = [NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0];
    [self addProperty:p named:_name];
    return p;
}
-(BoolProperty*) addPropB:(NSString*)_name {
    BoolProperty * p = [BoolProperty boolPropertyWithDefaultvalue:NO];
    [self addProperty:p named:_name];
    return p;
}

-(void) assignMidiChannel:(int) channel{
	[self setMidiChannel:[NSNumber numberWithInt:channel]];
    
	for(NSString * aKey in properties){
		[[properties valueForKey:aKey] setMidiChannel:[NSNumber numberWithInt:channel]];
	}	
}



-(IBAction) qlabAll:(id)sender{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Qlab alle properties?"];
	[alert setInformativeText:@"Dette kan have stor effekt på qlab!"];
	[alert setAlertStyle:NSWarningAlertStyle];
    //	[alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		NSLog(@"Go qlab");
		NSMutableArray * objects = [NSMutableArray arrayWithArray:[properties allValues]];
		[objects sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"midiNumber" ascending:YES]]]; 
		for(PluginProperty * p in objects){
			[p sendQlabNonVerbose];
		}
    }
	
}

-(IBAction) generateMidiNumbers:(id)sender{
	if([self midiChannel] == nil){		
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Midi channel not assigned!"];
		[alert setInformativeText:@"Assign this before you can generate midi numbers."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
	} else {
		
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert setMessageText:@"Assign new control numbers?"];
		[alert setInformativeText:@"This will (perhaps) change all the control numbers!"];
		[alert setAlertStyle:NSWarningAlertStyle];
		//	[alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		
		if ([alert runModal] == NSAlertFirstButtonReturn) {		
			NSMutableArray * objects = [NSMutableArray arrayWithArray:[properties allValues]];
			[objects sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]]; 
			int i=1;
			for(PluginProperty * p in objects){
				if([p forcedMidiNumber] && i < [[p midiNumber] intValue] + 1){
					i = [[p midiNumber] intValue] + 1;
				}
			}
			for(PluginProperty * p in objects){
				if(![p forcedMidiNumber]){
                    bool iFound = YES;
                    while(iFound == YES){
                        iFound = NO;
                        for(NSDictionary * header in [globalController plugins]){                        
                            
                            for(ofPlugin * otherPlugin in [header valueForKey:@"children"]){
                                for(PluginProperty * otherP in [[otherPlugin properties] allValues]){
                                    if(otherP != p && [[otherP midiChannel] isEqualToNumber:[p midiChannel]] && [[otherP midiNumber] intValue] == i){
                                        iFound = YES;
                                        i++;
                                    }
                                }
                            }
                        }
                    }
                    
                    if(!iFound){
                        [p setMidiNumber:[NSNumber numberWithInt:i]];
                    }
                    i++;
				}
			}
			[[globalController qlabController] updateQlabForPlugin:self];
		}
	}
}

@end

