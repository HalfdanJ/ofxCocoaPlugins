#pragma once

#include "Plugin.h"
#include "ofxOpenNI.h"

#import "Keystoner.h"
#import "KinectInstance.h"


struct Dancer {
	int userId;
	int state;
};




@interface Kinect : ofPlugin {	
	IBOutlet NSButton * drawCalibration;
	IBOutlet NSTabView * openglTabView;	
    IBOutlet NSPopUpButton *surfacePopUp;
    IBOutlet NSPopUpButton *kinectDevicePopUp;
    IBOutlet NSSegmentedControl *instanceSegmentedControl;
    
    NSMutableArray * surfaces;
    NSMutableArray * instances;
    NSMutableArray * availableDevices;
    
    ofxVec3f camCoord;
    ofxVec3f eyeCoord;

    float mouseLastX,mouseLastY;
    int draggedPoint;
    
    ofImage * handleImage;   
}

@property (readonly)  NSMutableArray * instances;
@property (readonly)  NSMutableArray * availableDevices;

-(IBAction) storeCalibration:(id)sender;
-(IBAction) setPriority:(id)sender;

-(id) initWithNumberKinects:(int)numberKinects;

-(KinectInstance*) getInstanceNumber:(int)num;
-(KinectInstance*) getSelectedConfigureInstance;

-(ofxTrackedUser*) getDancer:(int)d;




@end
