#ifdef KINECT

#pragma once

#include "Plugin.h"
#include "ofxOpenNI.h"

#import "Keystoner.h"
#import "KinectInstance.h"

//Define for not starting openni at startup and thereby having quicker startup (without code crashing)
//#define FASTDEBUG 


struct Dancer {
	int userId;
	int state;
};




@interface Kinect : ofPlugin {	
	IBOutlet NSButton * drawCalibration;
    IBOutlet NSButton *warpCalibration;
    IBOutlet NSButton *drawDepth;
	IBOutlet NSTabView * openglTabView;	
    IBOutlet NSPopUpButton *surfacePopUp;
    IBOutlet NSPopUpButton *kinectDevicePopUp;
    IBOutlet NSSegmentedControl *instanceSegmentedControl;    
    IBOutlet NSObjectController *instanceController;
    
    NSMutableArray * surfaces;
    NSMutableArray * instances;
    NSMutableArray * availableDevices;
    
    ofVec3f camCoord;
    ofVec3f eyeCoord;

    float mouseLastX,mouseLastY;
    int draggedPoint;
    
    ofImage * handleImage;   
}

@property (readonly)  NSMutableArray * instances;
@property (readonly)  NSMutableArray * availableDevices;

- (IBAction) storeCalibration:(id)sender;
- (IBAction) setPriority:(id)sender;
- (IBAction)setSelectedInstance:(id)sender;
- (IBAction)changeDevice:(id)sender;
- (IBAction)changeSurface:(id)sender;

- (IBAction) resetCalibration:(id)sender;
- (void) reset;

- (id) initWithNumberKinects:(int)numberKinects;

- (KinectInstance*) getInstance:(int)num;
- (KinectInstance*) getSelectedConfigureInstance;

- (ofxTrackedUser*) getDancer:(int)d;




@end

#endif