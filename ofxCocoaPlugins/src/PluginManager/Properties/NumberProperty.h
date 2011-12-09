
#import <Cocoa/Cocoa.h>

#import <ofxCocoaPlugins/PluginProperty.h>

@class PluginManagerController;
extern PluginManagerController * globalController;


@interface NumberProperty : PluginProperty {
	double minValue;
	double maxValue;
	
	float midiSmoothing;
	float midiGoal;
	bool valueSetFromMidi;
	NSDate * thisMidiTime;
	NSDate * lastMidiTime;

}
@property (readwrite) double minValue;
@property (readwrite) double maxValue;
@property (readwrite) float midiSmoothing; //closer to 1 is more smoothing (eg. 0.99)

+(NumberProperty*)sliderPropertyWithDefaultvalue:(float)defaultValue minValue:(float)min maxValue:(float)max;

-(void) setFloatValue:(float)v;
-(void) setIntValue:(int)v;
-(void) setBoolValue:(BOOL)v;
-(void) setDoubleValue:(double)v;
-(float)floatValue;
-(double)doubleValue;
-(int) intValue;
-(BOOL) boolValue;

-(void) clearSmoothing;

@end
