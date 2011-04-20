//
//  NumberProperty.m
//  loadnloop
//
//  Created by LoadNLoop on 24/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NumberProperty.h"
#import "QLabController.h"

@implementation NumberProperty
@synthesize minValue, maxValue, midiSmoothing;

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
        valueSetFromMidi = NO;
	}
	return self;
}

-(void) update{
	if(valueSetFromMidi && midiSmoothing > 0 && midiGoal != [self floatValue]){
		if(-[lastMidiTime timeIntervalSinceNow] < 6){
			if(fabs(midiGoal-[self floatValue]) < ([[self maxValue] floatValue]-[[self minValue] floatValue])*0.001){
				[self setFloatValue:midiGoal];
			} else {
				float f = [self floatValue] + (midiGoal - [self floatValue])*(1-midiSmoothing);
				[self setFloatValue:f];
				valueSetFromMidi = YES;
			}
		} else {
			[self setFloatValue:midiGoal];
			valueSetFromMidi = YES;
		}
		
		lastMidiTime = thisMidiTime;

	} 
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

-(void) setValue:(NSNumber*)n{
	[self willChangeValueForKey:@"value"];
	value = n;
	[self didChangeValueForKey:@"value"];
	valueSetFromMidi = NO;
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
	if(midiSmoothing > 0){
		midiGoal = endV;
		//cout<<"Got midi"<<midiGoal<<endl; 
		valueSetFromMidi = YES;
		thisMidiTime = [NSDate date];
	} else {
		[self setFloatValue:endV];
	}

}

-(NSNumber*)midiValue{
	float v = [self floatValue];
	v -= [[self minValue] floatValue];
	v /= ( [[self maxValue] floatValue] -  [[self minValue] floatValue]);
	v *= 127.0;
	v = ceil(v);
	return [NSNumber numberWithInt:v];
	
	
	
}
-(void) sendQlab{	
	[[globalController qlabController] startQlabTransaction:self fadingAllowed:YES verbose:YES];
}

-(void) sendQlabNonVerbose{
	[[globalController qlabController] startQlabTransaction:self fadingAllowed:NO verbose:NO];	
}



@end
