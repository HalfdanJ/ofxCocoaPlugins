//
//  BoolProperty.mm
//  loadnloop
//
//  Created by LoadNLoop on 31/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BoolProperty.h"


@implementation BoolProperty
//Creates only one slider that they all use.. The way you do it apparently
+(NSButtonCell*) buttonCell{
	static NSButtonCell * button;
	if(button == nil){
		button = [[NSButtonCell alloc] init];
		[button setBezelStyle:NSTexturedRoundedBezelStyle];
		[button setControlSize:NSMiniControlSize];
		[button setTitle:@"Toggle"];
	}
	
	return button;
}


+(BoolProperty*)boolPropertyWithDefaultvalue:(BOOL)defValue {
	static BoolProperty * prop = nil;
	prop = [[[BoolProperty alloc] init] autorelease];
	[prop setValue:[NSNumber numberWithBool:defValue]];
	[prop setDefaultValue: [NSNumber numberWithBool:defValue]];
	
	[prop setControlCell:[BoolProperty buttonCell]];	
	[prop setControlType:2];
	
	return prop;
}
/*
 -(id) init{
 if([super init]){
 //	[midiProperties setObject:[NSNumber numberWithInt:1] forKey:@"channel"];
 //	[midiProperties setObject:[NSNumber numberWithInt:1] forKey:@"number"];
 
 }
 return self;
 }*/



-(void) setFloatValue:(float)v{
	[self setValue:[NSNumber numberWithFloat:v]];
}

-(void) setIntValue:(int)v{
	[self setValue:[NSNumber numberWithInt:v]];
}

-(void) setBoolValue:(BOOL)v{
	[self setValue:[NSNumber numberWithBool:v]];
}

-(void) setDoubleValue:(double)v{
	[self setValue:[NSNumber numberWithDouble:v]];
}


-(float)floatValue{
	return [value floatValue];
}

-(double)doubleValue{
	return [value doubleValue];	
}

-(int) intValue{
	return [value intValue];
}

-(BOOL) boolValue{
	return [value boolValue];
}



-(NSCell *) controlCell{
	//	NSLog(@"Get controlcell with val %@",value);
	
	
	return controlCell;
	
}

-(void) encodeWithCoder:(NSCoder *)coder{
	[super encodeWithCoder:coder];
	//	[coder encodeObject:[self minValue] forKey:@"minVal"];
	//	[coder encodeObject:[self maxValue] forKey:@"maxVal"];
	
}

-(id) initWithCoder:(NSCoder *)coder{
	[super initWithCoder:coder];
	
	//	NSLog(@"Control type: %i",controlType);
	if(controlType == 2)
		[self setControlCell:[BoolProperty buttonCell]];	
	
	//[self setMinValue: [coder decodeObjectForKey:@"minVal"]];
	//[self setMaxValue: [coder decodeObjectForKey:@"maxVal"]];
	
	return self;
	
}

-(NSString *) description{
	return [NSString stringWithFormat:@"BoolProperty: %@", [value description]];
}

-(void) midiEvent:(int) _value{
	if(_value > 0){
		[self setBoolValue:YES];
	} else {
		[self setBoolValue:NO];		
	}
}

-(NSNumber*)midiValue{
	float v = [self floatValue];
	if(v > 0)
		v = 1;
	else {
		v = 0;
	}
	
	return [NSNumber numberWithInt:v];
	
	
	
}
-(void) sendQlab{	
	NSLog(@"Send to qlab %d %d %f %@", [midiChannel intValue], [midiNumber intValue], [value floatValue], name);
	
	int channel = [midiChannel intValue];
	int number = [midiNumber intValue];
	int val = [[self midiValue] intValue];
	NSString * str;
	if(val){
		str = [NSString stringWithFormat:@"%@ On", name];
	} else {
		str = [NSString stringWithFormat:@"%@ Off", name];
	}
	
	
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSAppleScript* scriptObject; 
	
	if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
		//make fading que
		scriptObject = [[NSAppleScript alloc] initWithSource:
						[NSString stringWithFormat:
//						 @"tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n activate\n tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n try\n get selected of front workspace\n on error\n  display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n  end try\n end tell\n tell front workspace\n  make type \"MIDI\"\n  set newCue to last item of (selected as list)\n  set channel of newCue to %d\n  set byte one of newCue to %d\n  set command of newCue to control_change\n  set end value of newCue to %d\n set fade of newCue to enabled\n set q name of newCue to \"%@ (fading)\"\n end tell\n end tell\n " , 
						 						 @"tell application \"QLab\" \n activate\n tell application \"QLab\"  \n try\n get selected of front workspace\n on error\n  display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n  end try\n end tell\n tell front workspace\n  make type \"MIDI\"\n  set newCue to last item of (selected as list)\n  set channel of newCue to %d\n  set byte one of newCue to %d\n  set command of newCue to control_change\n  set end value of newCue to %d\n set fade of newCue to enabled\n set q name of newCue to \"%@ (fading)\"\n end tell\n end tell\n \ntell application \"Hats, Trains & Planes Debug\" \n activate\n end tell \n " , 
						 [midiChannel intValue], [midiNumber intValue], val, name] 
						];
		
	} else {
		NSString * str = [NSString stringWithFormat:
						  @"tell application \"QLab\" \n  activate\n tell application \"QLab\" \n try\n get selected of front workspace\n on error\n display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n  buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n end try\n end tell\n  tell front workspace\n make type \"MIDI\"\n set newCue to last item of (selected as list)\n set channel of newCue to %d\n  set byte one of newCue to %d\n set command of newCue to control_change\n set byte two of newCue to %d\n set q name of newCue to  \"%@\"\n end tell\n end tell\n  \ntell application \"Hats, Trains & Planes Debug\" \n activate\n end tell \n" , 
//						  @"tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n  activate\n tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n try\n get selected of front workspace\n on error\n display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n  buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n end try\n end tell\n  tell front workspace\n make type \"MIDI\"\n set newCue to last item of (selected as list)\n set channel of newCue to %d\n  set byte one of newCue to %d\n set command of newCue to control_change\n set byte two of newCue to %d\n set q name of newCue to  \"%@\"\n end tell\n end tell\n " , 
						  //  @"%d %d %f %@",
						  channel, number, val, name] ;
		
		scriptObject = [[NSAppleScript alloc] initWithSource:
						str
						];
		
	}
	
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	//	NSLog(@"Error: %@",errorDict);
	//[scriptObject release];
	
}





@end
