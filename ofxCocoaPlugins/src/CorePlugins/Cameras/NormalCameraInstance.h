#include "CameraInstance.h"

@interface NormalCameraInstance : CameraInstance {
	NSString * guid;
	ofVideoGrabber * grabber;
    ofxCvColorImage * colorCVImage;
}

@property (retain) NSString * guid;


//+(NSMutableArray*) deviceList;

-(id)initWithGuid:(NSString*)guid named:(NSString*)name;
-(BOOL) openCamera;
@end
