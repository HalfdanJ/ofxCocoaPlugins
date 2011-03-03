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
	[[globalController qlabController] startQlabTransaction:self];

	/*
	int channel = [midiChannel intValue];
	int number = [midiNumber intValue];
	int val = [[self midiValue] intValue];
	if ([NSEvent modifierFlags] & NSAlternateKeyMask) {		
		NSString * str = [NSString stringWithFormat:@"to %i fading",val];		
		[self sendQlabScriptName:str channel:channel control:number value:val fade:true];
	} else {
		NSString * str = [NSString stringWithFormat:@"to %i",val];		
		[self sendQlabScriptName:str channel:channel control:number value:val fade:false];
		
	}	*/
}





@end
