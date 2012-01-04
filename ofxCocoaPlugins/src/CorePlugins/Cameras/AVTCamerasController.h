/*
 This class will deal with detecting AVT cameras, and create the instances for it
 */
#import "CamerasController.h"

#import "AVTCameraInstance.h"

@interface AVTCamerasController : CamerasController

-(void) cameraRecognized:(unsigned long) uid;
-(void) cameraUnplugged:(unsigned long) uid;
@end
