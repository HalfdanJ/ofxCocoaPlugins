#pragma once
#import <ofxCocoaPlugins/Plugin.h>


@interface OpenDMX : ofPlugin  {
	BOOL connected;
    NSMutableArray * dmxData;

}
@property (readonly) NSMutableArray * dmxData;
- (IBAction)setChannelValue:(id)sender;

-(void) setValue:(int)val forChannel:(int)channel;

@end
