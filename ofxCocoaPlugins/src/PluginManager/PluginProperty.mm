#include "GL/glew.h"

#import "PluginProperty.h"
#import "PluginManagerController.h"

#include "Midi.h"


static NSString *MidiControllerContext = @"org.ofx.midi.controller";

@implementation PluginProperty
@synthesize value, defaultValue, controlCell ,controlType, midiChannel, midiNumber, name, pluginName, forcedMidiNumber;

-(id) init{
	if([super init]){
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


-(const char *) objCType{
	return [value objCType];
}

-(NSString *) description{
	return @"PluginProptery";
}


- (id)copyWithZone:(NSZone*)zone{	
	return [self retain];
}




-(void) encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:value forKey:@"value"];
	[coder encodeObject:[self defaultValue] forKey:@"defvalue"];
	[coder encodeInt:[self controlType] forKey:@"controlType"];
	[coder encodeObject:midiChannel forKey:@"midiChannel"];
	[coder encodeObject:midiNumber forKey:@"midiNumber"];
}

-(id) initWithCoder:(NSCoder *)coder{
	[self setValue:[coder decodeObjectForKey:@"value"]];
	[self setDefaultValue: [coder decodeObjectForKey:@"defvalue"]];
	[self setControlType: [coder decodeIntForKey:@"controlType"]];
	[self setMidiChannel:[coder decodeObjectForKey:@"midiChannel"]];
	[self setMidiNumber:[coder decodeObjectForKey:@"midiNumber"]];
	
	return self;
}
-(void) midiEvent:(int) value{};

-(void) bindMidi{
	if(midiChannel != nil && midiNumber != nil){		
		binded = YES;

		[[[GetPlugin(Midi) midiData] objectAtIndex:[midiChannel intValue]] addObserver:self forKeyPath:[midiNumber stringValue] options:0 context:MidiControllerContext];
	}
}
-(void) unbindMidi{
	if(binded){		
		[[[GetPlugin(Midi) midiData] objectAtIndex:[midiChannel intValue]] removeObserver:self forKeyPath:[midiNumber stringValue]];
		binded = NO;
	}	
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
