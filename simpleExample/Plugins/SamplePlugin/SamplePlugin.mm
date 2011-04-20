#import "SamplePlugin.h"
#import "Keystoner.h"

@implementation SamplePlugin

-(void) initPlugin{
	[self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.5 minValue:-1 maxValue:1] named:@"width"];
	[self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.5 minValue:0 maxValue:1] named:@"height"];
	[self addProperty:[BoolProperty boolPropertyWithDefaultvalue:1] named:@"green"];
}

-(void) setup{
	
}

-(void) update:(NSDictionary *)drawingInformation{
	[[properties objectForKey:@"width"] setFloatValue:sin([[drawingInformation valueForKey:@"outputTime.videoTime"] doubleValue] / 200000000.0)];
}

-(void) draw:(NSDictionary*)drawingInformation{
	ApplySurface(@"Floor");{
		ofFill();
		ofSetColor(255, 0, 0,255);
		
		if([[properties objectForKey:@"green"] boolValue]){
			ofSetColor(0, 255, 0,255);		
		}
		
		ofRect(0.5, 0, [[properties objectForKey:@"width"] floatValue]*0.5, [[properties objectForKey:@"height"] floatValue]);
		ofSetColor(255,255,255);
		glScaled(1.0/640, 1.0/480, 1);
		ofDrawBitmapString("Output "+ofToString([[drawingInformation valueForKey:@"outputViewNumber"] intValue], 0), 10, 40);
	}PopSurface();
}


@end
