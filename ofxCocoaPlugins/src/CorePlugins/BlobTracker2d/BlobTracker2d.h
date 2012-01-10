#pragma once

#include <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/BlobTrackerInstance2d.h>

//To use the kinect aswell as camera source
//#define USE_KINECT_2D_TRACKER

@interface BlobTracker2d : ofPlugin {
    NSMutableArray * instances;    
    
    int controlHeight;
    int controlWidth;     
}

-(BlobTrackerInstance2d*) getInstance:(int) num;

@end
