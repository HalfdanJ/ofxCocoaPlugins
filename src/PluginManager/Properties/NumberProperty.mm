//
//  NumberProperty.m
//  loadnloop
//
//  Created by LoadNLoop on 24/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NumberProperty.h"

@implementation NumberProperty
@synthesize minValue, maxValue;

//Creates only one slider that they all use.. The way you do it apparently
+(NSSliderCell*) sliderCell{
	static NSSliderCell * slider;
	if(slider == nil){
		slider = [[NSSliderCell alloc] init];
	}
	
	return slider;
}

-(void) dealloc{
	[minValue release];
	[maxValue release];
	[super dealloc];
}


+(NumberProperty*)sliderPropertyWithDefaultvalue:(float)defValue minValue:(float)min maxValue:(float)max{
	static NumberProperty * prop = nil;
	prop = [[[NumberProperty alloc] init] autorelease];
	[prop setValue:[NSNumber numberWithFloat:defValue]];
	[prop setDefaultValue: [NSNumber numberWithFloat:defValue]];
	
	[prop setMinValue: [NSNumber numberWithFloat:min]];
	[prop setMaxValue: [NSNumber numberWithFloat:max]];
	
	[prop setControlCell:[NumberProperty sliderCell]];	
	[prop setControlType:1];
	
	return prop;
}

-(id) init{
	if([super init]){
	}
	return self;
}



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
	[(NSSliderCell*)controlCell setMinValue:[[self minValue] floatValue] ];
	[(NSSliderCell*)controlCell setMaxValue:[[self maxValue] floatValue] ];		
	
	
	return controlCell;
	
}

-(void) encodeWithCoder:(NSCoder *)coder{
	[super encodeWithCoder:coder];
	[coder encodeObject:[self minValue] forKey:@"minVal"];
	[coder encodeObject:[self maxValue] forKey:@"maxVal"];
	
}

-(id) initWithCoder:(NSCoder *)coder{
	[super initWithCoder:coder];
	
	//	NSLog(@"Control type: %i",controlType);
	if(controlType == 1)
		[self setControlCell:[NumberProperty sliderCell]];	
	
	[self setMinValue: [coder decodeObjectForKey:@"minVal"]];
	[self setMaxValue: [coder decodeObjectForKey:@"maxVal"]];
	
	return self;
	
}

-(NSString *) description{
	return [NSString stringWithFormat:@"NumberProperty: %@", [value description]];
}

-(void) midiEvent:(int) _value{
	float v = _value/127.0;
	float endV = [[self minValue] floatValue] + ( [[self maxValue] floatValue] -  [[self minValue] floatValue])*v;
	[self setFloatValue:endV];
}

-(NSNumber*)midiValue{
	float v = [self floatValue];
	v -= [[self minValue] floatValue];
	v /= ( [[self maxValue] floatValue] -  [[self minValue] floatValue]);
	v *= 127.0;
	
	return [NSNumber numberWithInt:v];
	
	
	
}
-(void) sendQlab{	
	NSLog(@"Send to qlab %d %d %f %@", [midiChannel intValue], [midiNumber intValue], [value floatValue], name);
	
	int channel = [midiChannel intValue];
	int number = [midiNumber intValue];
	int val = [[self midiValue] intValue];
	if ([NSEvent modifierFlags] & NSAlternateKeyMask) {		
		NSString * str = [NSString stringWithFormat:@"%@ to %i fading",name,val];		
		[self sendQlabScriptName:str channel:channel control:number value:val fade:true];
	} else {
		NSString * str = [NSString stringWithFormat:@"%@ to %i",name,val];		
		[self sendQlabScriptName:str channel:channel control:number value:val fade:false];
		
	}
	
	
	/*NSDictionary* errorDict;
	 NSAppleEventDescriptor* returnDescriptor = NULL;
	 
	 NSAppleScript* scriptObject; 
	 
	 if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
	 //make fading que
	 scriptObject = [[NSAppleScript alloc] initWithSource:
	 [NSString stringWithFormat:
	 // @"tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n activate\n tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n try\n get selected of front workspace\n on error\n  display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n  end try\n end tell\n tell front workspace\n  make type \"MIDI\"\n  set newCue to last item of (selected as list)\n  set channel of newCue to %d\n  set byte one of newCue to %d\n  set command of newCue to control_change\n  set end value of newCue to %d\n set fade of newCue to enabled\n set q name of newCue to \"%@ (fading)\"\n end tell\n end tell\n " , 
	 @"tell application \"QLab\" \n activate\n tell application \"QLab\" \n try\n get selected of front workspace\n on error\n  display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n  end try\n end tell\n tell front worksp scriptace\n  make type \"MIDI\"\n  set newCue to last item of (selected as list)\n  set channel of newCue to %d\n  set byte one of newCue to %d\n  set command of newCue to control_change\n  set end value of newCue to %d\n set fade of newCue to enabled\n set q name of newCue to \"%@ (fading)\"\n end tell\n end tell \ntell application \"Hats, Trains & Planes Debug\" \n activate\n end tell \n " , 
	 [midiChannel intValue], [midiNumber intValue], val, name] 
	 ];
	 
	 } else {
	 NSString * str = [NSString stringWithFormat:
	 //@"tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n  activate\n tell application \"QLab\" of machine \"eppc://jonas:Uimx88@halfdanj.local\" \n try\n get selected of front workspace\n on error\n display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n  buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n end try\n end tell\n  tell front workspace\n make type \"MIDI\"\n set newCue to last item of (selected as list)\n set channel of newCue to %d\n  set byte one of newCue to %d\n set command of newCue to control_change\n set byte two of newCue to %d\n set q name of newCue to  \"%@\"\n end tell\n end tell\n " , 
	 @"tell application \"QLab\" \n  activate\n tell application \"QLab\" \n try\n get selected of front workspace\n on error\n display dialog \"There is no workspace open in QLab.\" with title \"Error\" with icon 0 ¬\n  buttons {\"OK\"} default button \"OK\" giving up after 5\n return\n end try\n end tell\n  tell front workspace\n make type \"MIDI\"\n set newCue to last item of (selected as list)\n set channel of newCue to %d\n  set byte one of newCue to %d\n set command of newCue to control_change\n set byte two of newCue to %d\n set q name of newCue to  \"%@\"\n end tell\n end tell\n  \ntell application \"Hats, Trains & Planes Debug\" \n activate\n end tell \n" , 
	 //  @"%d %d %f %@",
	 channel, number, val, name] ;
	 
	 scriptObject = [[NSAppleScript alloc] initWithSource:
	 str
	 ];
	 
	 }
	 
	 returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	 //	NSLog(@"Error: %@",errorDict);
	 //[scriptObject release];
	 */
	
	
}





@end
