#import "CamerasController.h"
#import "CameraInstance.h"

@implementation CamerasController
@synthesize instances = _instances;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(NSString *)description{
    return @"Cameras Controller";
}

-(void) closeCameras{
    for(CameraInstance * instance in [self instances]){
        [instance close];
    }
}

@end
