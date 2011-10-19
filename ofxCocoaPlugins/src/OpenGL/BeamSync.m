//
//  BeamSync.m
//  Example
//
//  Created by Se Min Skygge on 18/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


extern void CGSSetDebugOptions(int);
extern void CGSDeferredUpdates(int);

typedef enum {
    disableBeamSync = 0,
    automaticBeamSync = 1,
    forcedBeamSyncMode = 2
} beamSyncMode;



#import "BeamSync.h"


@implementation BeamSync

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+(void) disable{
    //Disable beam sync
    beamSyncMode mode = disableBeamSync;
    
    CGSSetDebugOptions(mode ? 0 : 0x08000000);
    CGSDeferredUpdates(mode);
}

+(void) enable{
    //Disable beam sync
    beamSyncMode mode = automaticBeamSync;
    
    CGSSetDebugOptions(mode ? 0 : 0x08000000);
    CGSDeferredUpdates(mode);
}


@end
