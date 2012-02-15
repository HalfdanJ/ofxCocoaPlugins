#include "GL/glew.h"

#import "PluginProperty.h"
#import "PluginManagerController.h"

#include "Midi.h"


static NSString *MidiControllerContext = @"org.ofx.midi.controller";

@implementation PluginProperty
@synthesize value, defaultValue, controlCell ,controlType, midiChannel, midiNumber, name, pluginName, forcedMidiNumber, midiLabel, context;

-(id) init{
	if(self = [super init]){
		binded = NO;
		forcedMidiNumber = NO;
        [self setMidiLabel:@"-"];
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
-(void) midiEvent:(int) _value{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setMidiLabel:[NSString stringWithFormat:@"^ %i",_value]];
    }];
};

-(void) bindMidi{
	if(midiChannel != nil && midiNumber != nil){		
		binded = YES;

		[[[GetPlugin(Midi) midiData] objectAtIndex:[midiChannel intValue]] addObserver:self forKeyPath:[NSString stringWithFormat:@"cc%i",[midiNumber intValue]] options:0 context:MidiControllerContext];
        
        [self setMidiLabel:[NSString stringWithFormat:@"%i", [[self midiValue] intValue]]];
	}
}
-(void) unbindMidi{
	if(binded){		
		[[[GetPlugin(Midi) midiData] objectAtIndex:[midiChannel intValue]] removeObserver:self forKeyPath:[NSString stringWithFormat:@"cc%i",[midiNumber intValue]]];
		binded = NO;
        [self setMidiLabel:@"-"];
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
                    //[[globalController openglLock] lock]; //Had some trouble with mutations during enumerations

					[self midiEvent:[[(NSDictionary*)[object midiData] objectForKey:@"value"] intValue]];
                 //   [[globalController openglLock] unlock]; 
				}	
			}
		}
	}
}

-(void) setMidiChannel:(NSNumber *)n{
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
}

-(void) update{
}


-(void) setMidiNumber:(NSNumber *)n{
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
}

/*-(void) setManualMidiNumber:(NSNumber*)number{
	forcedMidiNumber = YES;
	[self setMidiNumber:number];
	
}*/

-(void) reset{
	[self setValue:defaultValue];
}

-(NSNumber *)midiValue{return nil;}
-(void)sendQlab{};
-(void)sendQlabNonVerbose{}

@end
