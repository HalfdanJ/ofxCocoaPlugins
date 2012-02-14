#import "PluginManagerController.h"
#import "NumberProperty.h"
#import "QLabController.h"

#import <ScriptingBridge/ScriptingBridge.h>


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
	[super dealloc];
}

-(void)clearSmoothing{
    lastMidiTime = nil;    
}

+(NumberProperty*)sliderPropertyWithDefaultvalue:(float)defValue minValue:(float)min maxValue:(float)max{
	static NumberProperty * prop = nil;
	prop = [[[NumberProperty alloc] init] autorelease];
	[prop setValue:[NSNumber numberWithFloat:defValue]];
	[prop setDefaultValue: [NSNumber numberWithFloat:defValue]];
	
	[prop setMinValue: min];
	[prop setMaxValue: max];
	
	[prop setControlCell:[NumberProperty sliderCell]];	
	[prop setControlType:1];
	
	return prop;
}

-(id) init{
	if(self = [super init]){
        valueSetFromMidi = NO;
	}
	return self;
}

-(void) update{
        
        if(valueSetFromMidi && midiSmoothing > 0 && midiGoal != [self floatValue]){
            if(lastMidiTime != nil && -[lastMidiTime timeIntervalSinceNow] < 6){
                if(fabs(midiGoal-[self floatValue]) < ([self maxValue]-[self minValue])*0.001){
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
	value = n;
	valueSetFromMidi = NO;
    if(binded){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self setMidiLabel:[NSString stringWithFormat:@"%i", [[self midiValue] intValue]]];
        }];
    }
}

-(NSCell *) controlCell{
	//	NSLog(@"Get controlcell with val %@",value);
	[(NSSliderCell*)controlCell setMinValue:[self minValue] ];
	[(NSSliderCell*)controlCell setMaxValue:[self maxValue] ];		
	
	
	return controlCell;
	
}

-(void) encodeWithCoder:(NSCoder *)coder{
	[super encodeWithCoder:coder];
	[coder encodeObject:[NSNumber numberWithDouble:[self minValue]] forKey:@"minVal"];
	[coder encodeObject:[NSNumber numberWithDouble:[self maxValue]] forKey:@"maxVal"];
	
}

-(id) initWithCoder:(NSCoder *)coder{
	self = [super initWithCoder:coder];
	
	//	NSLog(@"Control type: %i",controlType);
	if(controlType == 1)
		[self setControlCell:[NumberProperty sliderCell]];	
	
	[self setMinValue: [[coder decodeObjectForKey:@"minVal"] doubleValue]];
	[self setMaxValue: [[coder decodeObjectForKey:@"maxVal"] doubleValue]];
	
	return self;
	
}

-(NSString *) description{
	return [NSString stringWithFormat:@"NumberProperty: %@", [value description]];
}

-(void) midiEvent:(int) _value{
	float v = _value/127.0;
	float endV = [self minValue]  + ( [self maxValue] -  [self minValue])*v;
	if(midiSmoothing > 0){
		midiGoal = endV;
		//cout<<"Got midi"<<midiGoal<<endl; 
		valueSetFromMidi = YES;
		thisMidiTime = [NSDate date];
	} else {
		[self setFloatValue:endV];
	}
    [super midiEvent:_value];
    
}

-(NSNumber*)midiValue{
	float v = [self floatValue];
	v -= [self minValue] ;
	v /= ( [self maxValue]  -  [self minValue] );
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

-(void) setMinValue:(double)_minValue maxValue:(double)_maxValue{
    [self setMinValue:_minValue];
    [self setMaxValue:_maxValue];
}

@end
