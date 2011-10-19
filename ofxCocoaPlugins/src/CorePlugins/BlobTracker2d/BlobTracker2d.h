#pragma once

#include "Plugin.h"

#import "BlobTrackerInstance2d.h"

@interface BlobTracker2d : ofPlugin {
    NSMutableArray * instances;    
    
    int controlHeight;
    int controlWidth; 
    
}

-(BlobTrackerInstance2d*) getInstance:(int) num;

@end
