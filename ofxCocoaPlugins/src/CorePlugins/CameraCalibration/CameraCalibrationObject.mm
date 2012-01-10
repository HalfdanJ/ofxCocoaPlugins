
#import "CameraCalibrationObject.h"

@implementation CameraCalibrationObject
@synthesize camera, surface, active;


-(id) initWithCamera:(Camera*)_camera surface:(NSString*)_surface{
    self = [super init];
    if (self) {
        camera = _camera;
        surface = _surface;
    }
    return self;
}
@end
