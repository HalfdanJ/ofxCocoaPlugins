#pragma once

#include "Plugin.h"

@interface CamerasController : NSObject {
    NSMutableArray * _instances;
}

//List all the available camera instances
@property (readwrite, retain) NSMutableArray * instances;

-(void) closeCameras;

@end
