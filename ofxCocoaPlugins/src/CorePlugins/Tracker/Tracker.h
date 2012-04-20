#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import "ofxCvMain.h"

enum TrackerSource {
    UnknownSource,
    OSCControlSource,
    MouseSource,
    CameraSource
};
typedef enum TrackerSource TrackerSource;

@interface Tracker : ofPlugin {
    ofVec2f controlMouse;
}

-(TrackerSource) trackerSource:(int)n;

-(int) numberTrackers;
-(ofVec2f) trackerCentroid:(int)n;
-(vector<ofVec2f>) trackerCentroidVector;

-(vector<ofVec2f>) trackerBlob:(int)n;
-(vector< vector<ofVec2f> >) trackerBlobVector;

-(ofVec2f) trackerFeet:(int)n;
-(vector<ofVec2f>) trackerFeetVector;

-(ofxCvGrayscaleImage) trackerImageWithSize:(CGSize)res;

@end
