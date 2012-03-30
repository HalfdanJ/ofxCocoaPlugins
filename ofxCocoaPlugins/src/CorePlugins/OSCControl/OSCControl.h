#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import "ofxOsc.h"

struct oscTrackerData {
    bool active;
    ofVec2f point;
};

@interface OSCControl : ofPlugin {
    ofxOscSender * sender;
    ofxOscReceiver * receiver;
    
    oscTrackerData trackerData[10];
}

- (oscTrackerData) getTracker:(int)tracker;
- (vector<ofVec2f>) getTrackerCoordinates;

- (void) setColor:(NSString*)widget background:(NSString*)background foreground:(NSString*)foreground stroke:(NSString*)stroke ;
@end
