#import "PluginProperty.h"
#include "GraphDebugger.h"
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
			if([[[object midiData]objectForKey:@"number"] intValue] == [midiNumber intValue]){			
				if([[[object midiData]objectForKey:@"channel"] intValue] == [midiChannel intValue]){
					[self midiEvent:[[[object midiData] objectForKey:@"value"] intValue]];
				}	
			}
		}
	}
}

-(void) setMidiChannel:(NSNumber *)n{
	[self willChangeValueForKey:@"midiChannel"];
	if(midiChannel != nil)
		[midiChannel release];
	
	midiChannel = [n retain];
	
	if(midiChannel != nil && !binded){
		[self bindMidi];
	} else {
		if(binded){
			[self unbindMidi];
			[self bindMidi];
		}
	}
	[self didChangeValueForKey:@"midiChannel"];
}

-(void) update{
}


-(void) setMidiNumber:(NSNumber *)n{
	[self willChangeValueForKey:@"midiNumber"];
	if(midiNumber != nil)
		[midiNumber release];
	
	midiNumber = [n retain];
	
	if(midiNumber != nil && !binded){
		[self bindMidi];
	} else {
		if(binded){
			[self unbindMidi];
			[self bindMidi];
		}
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

/*
-(void) sendQlabScriptName:(NSString*)description channel:(int)channel control:(int)control value:(int)value fade:(bool)fade{
	NSString* path = [[NSBundle mainBundle] pathForResource:@"SendToQlab" ofType:@"scpt"];
    if (path != nil)
    {
        NSURL* url = [NSURL fileURLWithPath:path];
        if (url != nil)
        {
            NSDictionary* errors = [NSDictionary dictionary];
            NSAppleScript* appleScript =
			[[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
            if (appleScript != nil)
            {
                // create the first parameter
                NSAppleEventDescriptor* firstParameter = [NSAppleEventDescriptor descriptorWithString:[NSString stringWithFormat:@"%@: %@ %@",pluginName, name, description]];
                NSAppleEventDescriptor* secondParameter = [NSAppleEventDescriptor descriptorWithInt32:channel];
                NSAppleEventDescriptor* thirdParameter = [NSAppleEventDescriptor descriptorWithInt32:control];
				NSAppleEventDescriptor* fourthParameter = [NSAppleEventDescriptor descriptorWithInt32:value];
				NSAppleEventDescriptor* fifthParameter = [NSAppleEventDescriptor descriptorWithInt32:fade];
				
                // create and populate the list of parameters (in our case just one)
                NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
                [parameters insertDescriptor:firstParameter atIndex:1];
                [parameters insertDescriptor:secondParameter atIndex:2];
				[parameters insertDescriptor:thirdParameter atIndex:3];
				[parameters insertDescriptor:fourthParameter atIndex:4];
				[parameters insertDescriptor:fifthParameter atIndex:5];

                // create the AppleEvent target
                ProcessSerialNumber psn = {0, kCurrentProcess};
                NSAppleEventDescriptor* target =
                [NSAppleEventDescriptor
				 descriptorWithDescriptorType:typeProcessSerialNumber
				 bytes:&psn
				 length:sizeof(ProcessSerialNumber)];
				
                // create an NSAppleEventDescriptor with the script's method name to call,
                // this is used for the script statement: "on show_message(user_message)"
                // Note that the routine name must be in lower case.
                NSAppleEventDescriptor* handler =
				[NSAppleEventDescriptor descriptorWithString:
				 [@"send_qlab" lowercaseString]];
				
                // create the event for an AppleScript subroutine,
                // set the method name and the list of parameters
                NSAppleEventDescriptor* event =
				[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
														 eventID:kASSubroutineEvent
												targetDescriptor:target
														returnID:kAutoGenerateReturnID
												   transactionID:kAnyTransactionID];
                [event setParamDescriptor:handler forKeyword:keyASSubroutineName];
                [event setParamDescriptor:parameters forKeyword:keyDirectObject];
				
                // call the event in AppleScript
                if (![appleScript executeAppleEvent:event error:&errors]);
                {
                    // report any errors from 'errors'
                }
				
                [appleScript release];
            }
            else
            {
                // report any errors from 'errors'
            }
        }
    }
}*/
@end
