#import "PluginProperty.h"

#include "Midi.h"


static NSString *MidiControllerContext = @"org.recoil.midi.controller";

@implementation PluginProperty
@synthesize value, defaultValue, controlCell ,controlType, midiChannel, midiNumber, name, pluginName, forcedMidiNumber;

-(id) init{
	if([super init]){
		graphDebugging = NO;
		//	midiProperties = [[NSMutableDictionary dictionary] retain];
		binded = NO;
		forcedMidiNumber = NO;
	}
	return self;
}

-(void) dealloc{
	[value release];
	[defaultValue release];
	[midiChannel release];
	[midiNumber release];
	[name release];
	[super dealloc];
}
/*
 +(PluginProperty*)boolProperty:(BOOL)defValue {
 static PluginProperty * prop = nil;
 prop = [[PluginProperty alloc] init];
 [prop setType:BOOL_PROPERTY];
 [prop setValue:[NSNumber numberWithFloat:defValue]];
 [prop setDefaultValue: [NSNumber numberWithFloat:defValue]];
 
 return prop;
 
 }
 
 +(PluginProperty*)stringProperty:(NSString*)defValue{
 static PluginProperty * prop = nil;
 prop = [[PluginProperty alloc] init];
 [prop setType:STRING_PROPERTY];
 [prop setValue:[NSString stringWithString:defValue]];
 [prop setDefaultValue: [NSString stringWithString:defValue]];
 
 return prop;
 
 
 }
 */
-(const char *) objCType{
	return [value objCType];
}

-(NSString *) description{
	//return [value description];
	return @"PluginProptery";
}


- (id)copyWithZone:(NSZone*)zone
{	
	return [self retain];
}


-(NSNumber *) graph{
	return [NSNumber numberWithBool:graphDebugging];
}

-(void) setGraph:(NSNumber *)b{
	graphDebugging = [b boolValue];
/*	
	if(graphDebugging){
		[globalGraphDebugger addProperty:self];
	} else {
		[globalGraphDebugger removeProperty:self];		
	}*/
}


-(void) encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:value forKey:@"value"];
	[coder encodeObject:[self defaultValue] forKey:@"defvalue"];
	[coder encodeInt:[self controlType] forKey:@"controlType"];
	[coder encodeObject:midiChannel forKey:@"midiChannel"];
	[coder encodeObject:midiNumber forKey:@"midiNumber"];
	//	NSLog(@"Encode controlType %i",[self controlType]);
}

-(id) initWithCoder:(NSCoder *)coder{
	[self setValue:[coder decodeObjectForKey:@"value"]];
	[self setDefaultValue: [coder decodeObjectForKey:@"defvalue"]];
	[self setControlType: [coder decodeIntForKey:@"controlType"]];
	[self setMidiChannel:[coder decodeObjectForKey:@"midiChannel"]];
	[self setMidiNumber:[coder decodeObjectForKey:@"midiNumber"]];
	
	//	NSLog(@"Decode controlType %i",[self controlType]);	
	
	return self;
}
-(void) midiEvent:(int) value{};

-(void) bindMidi{
	if(midiChannel != nil && midiNumber != nil){		
		binded = YES;

		[[[GetPlugin(Midi) midiData] objectAtIndex:[midiChannel intValue]] addObserver:self forKeyPath:[midiNumber stringValue] options:0 context:MidiControllerContext];
		
		//	[[GetPlugin(Midi) midiBindings] addObject:midiProperties];
	}
}
-(void) unbindMidi{
	if(binded){		
		[[[GetPlugin(Midi) midiData] objectAtIndex:[midiChannel intValue]] removeObserver:self forKeyPath:[midiNumber stringValue]];
//		[[[GetPlugin(Midi) midiData] objectForKey:midiChannel] removeObserver:self forKeyPath:midiNumber];
		binded = NO;
	}	
	//[[GetPlugin(Midi) midiBindings] removeObject:midiProperties];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if (context == MidiControllerContext) {
		if(midiChannel != nil && midiNumber != nil){
			[self midiEvent:[[object objectForKey:keyPath] intValue]];
		}
	}
	
	if([keyPath isEqualToString:@"intValue"]){
		if(midiChannel != nil && midiNumber != nil){
			[self midiEvent:[object intValue]];
		}
	}
	
	if([keyPath isEqualToString:@"midiData"]){
		if(midiChannel != nil && midiNumber != nil){
			if([[(NSDictionary*)[object midiData]objectForKey:@"number"] intValue] == [midiNumber intValue]){			
				if([[(NSDictionary*)[object midiData]objectForKey:@"channel"] intValue] == [midiChannel intValue]){
					[self midiEvent:[[(NSDictionary*)[object midiData] objectForKey:@"value"] intValue]];
				}	
			}
		}
	}
}

-(void) setMidiChannel:(NSNumber *)n{
	[self willChangeValueForKey:@"midiChannel"];
	if(midiChannel != nil && !binded){
	} else {
		if(binded){
			[self unbindMidi];
		}
	}
	
	
	if(midiChannel != nil)
		[midiChannel release];
	
	midiChannel = [n retain];
	
	if(midiChannel != nil && !binded){
		[self bindMidi];
	} 
	[self didChangeValueForKey:@"midiChannel"];
}

-(void) update{
}


-(void) setMidiNumber:(NSNumber *)n{
	[self willChangeValueForKey:@"midiNumber"];
	if(midiNumber != nil && !binded){
	} else {
		if(binded){
			[self unbindMidi];
		}
	}

	
	
	if(midiNumber != nil)
		[midiNumber release];
	
	midiNumber = [n retain];
	
	if(midiNumber != nil && !binded){
		[self bindMidi];
	} 
	[self didChangeValueForKey:@"midiNumber"];
}

-(void) setManualMidiNumber:(NSNumber*)number{
	forcedMidiNumber = YES;
	[self setMidiNumber:number];
	
}

-(void) reset{
	[self setValue:defaultValue];
}

-(NSNumber *)midiValue{return nil;}
-(void)sendQlab{};
-(void)sendQlabNonVerbose{}

@end
