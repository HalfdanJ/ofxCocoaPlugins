#pragma once

#include "Plugin.h"

#include "ofxOpenNI.h"
#import "Keystoner.h"

@class Kinect;

@interface KinectInstance : NSObject {
    ofxOpenNIContext  context;
	ofxDepthGenerator  depth;
    ofxIRGenerator ir;
	ofxUserGenerator  users;
    
    BOOL kinectConnected;
	BOOL stop;

    float scale, scalex;


    ofxPoint2f projPointCache[3];
	ofxPoint2f point2Cache[3];
	ofxPoint3f point3Cache[3];
    
    ofxQuaternion rotationQuaternion;
    
    KeystoneSurface * surface;   
    Kinect * kinectController;

    const char * deviceChar;
    int bus;
}

@property (readwrite, assign) KeystoneSurface * surface;
@property (readwrite, assign)  Kinect * kinectController;

@property (readonly) BOOL kinectConnected;
@property (readwrite) const char * deviceChar;
@property (readwrite) int bus;

-(void) setup;
-(void) update:(NSDictionary *)drawingInformation;

-(ofxPoint2f) point2:(int)point;
-(ofxPoint3f) point3:(int)point;
-(ofxPoint2f) projPoint:(int)point;

-(void) setPoint3:(int) point coord:(ofxPoint3f)coord;
-(void) setPoint2:(int) point coord:(ofxPoint2f)coord;
-(void) setProjPoint:(int) point coord:(ofxPoint2f)coord;

-(ofxPoint3f) convertKinectToWorld:(ofxPoint3f)p;
-(ofxPoint3f) convertWorldToKinect:(ofxPoint3f)p;
-(ofxPoint3f) convertWorldToProjection:(ofxPoint3f) p;
-(ofxPoint3f) convertWorldToSurface:(ofxPoint3f) p;
-(ofxPoint3f) convertSurfaceToWorld:(ofxPoint3f) p;

-(vector<ofxPoint3f>) getPointsInBoxXMin:(float)xMin xMax:(float)xMax yMin:(float)yMin yMax:(float)yMax zMin:(float)zMin zMax:(float)zMax res:(int)res;

-(void) calculateMatrix;

-(float) surfaceAspect;

-(ofxUserGenerator*) getUserGenerator;
-(IBAction) resetCalibration:(id)sender;
-(void) reset;

-(KeystoneSurface*) surface;

-(ofxDepthGenerator*) getDepthGenerator;
-(ofxIRGenerator*) getIRGenerator;


@end
