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
/*	NSLog(@"Send to qlab %d %d %f %@", [midiChannel intValue], [midiNumber intValue], [value floatValue], name);
	
	int channel = [midiChannel intValue];
	int number = [midiNumber intValue];
	int val = [[self midiValue] intValue];
	NSString * str;
	if(val){
		str = [NSString stringWithFormat:@"%@ On", name];
	} else {
		str = [NSString stringWithFormat:@"%@ Off", name];
	}
	
	[self sendQlabScriptName:str channel:channel control:number value:val fade:NO];
*/
	[[globalController qlabController] startQlabTransaction:self fadingAllowed:NO verbose:YES];		
}

-(void) sendQlabNonVerbose{
	[[globalController qlabController] startQlabTransaction:self fadingAllowed:NO verbose:NO];	
}





@end
