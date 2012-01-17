#ifdef KINECT

#pragma once

#include "Plugin.h"

#include "ofxOpenNI.h"

#import "Keystoner.h"

@class Kinect;

@interface KinectInstance : NSObject {
    ofxOpenNIContext  context;
	ofxDepthGenerator  depth;
    ofxIRGenerator ir;
    ofxImageGenerator color;
	ofxUserGenerator  users;
    
    BOOL kinectConnected;
    BOOL connectionRefused;
	BOOL stop;
    BOOL colorEnabled;

    float scale, scalex;


    ofVec2f projPointCache[4];
	ofVec2f point2Cache[4];
	ofVec3f point3Cache[3];
    
    ofxQuaternion rotationQuaternion;
    
    KeystoneSurface * surface;   
    Kinect * kinectController;

    NSString * deviceChar;
    int bus;
    int adr;
    
    float angle1, angle2;
    
    int kinectNumber;
    
    BOOL irEnabled;
    BOOL calibration2d;
    
    float levelsLow, levelsHigh;
    
    coordWarping * coordWarper;
}

@property (readwrite, assign) KeystoneSurface * surface;
@property (readwrite, assign)  Kinect * kinectController;

@property (readonly) BOOL kinectConnected;
@property (readwrite, assign) NSString * deviceChar;
@property (readwrite) int bus;
@property (readwrite) int adr;
@property (readwrite) BOOL stop;
@property (readwrite) BOOL colorEnabled;

@property (readwrite) int kinectNumber;
@property (readwrite) BOOL irEnabled;
@property (readwrite) BOOL calibration2d;

@property (readwrite) float levelsLow;
@property (readwrite) float levelsHigh;

@property (readwrite) coordWarping * coordWarper;

-(void) setup;
-(void) update:(NSDictionary *)drawingInformation;

-(ofVec2f) point2:(int)point;
-(ofVec3f) point3:(int)point;
-(ofVec2f) projPoint:(int)point;

-(void) setPoint3:(int) point coord:(ofVec3f)coord;
-(void) setPoint2:(int) point coord:(ofVec2f)coord;
-(void) setProjPoint:(int) point coord:(ofVec2f)coord;
-(ofVec2f) surfaceCorner:(int)n;

-(ofVec3f) convertKinectToWorld:(ofVec3f)p;
-(ofVec3f) convertWorldToKinect:(ofVec3f)p;
-(ofVec3f) convertWorldToProjection:(ofVec3f) p;
-(ofVec3f) convertWorldToSurface:(ofVec3f) p;
-(ofVec3f) convertSurfaceToWorld:(ofVec3f) p;

-(vector<ofVec3f>) getPointsInBoxXMin:(float)xMin xMax:(float)xMax yMin:(float)yMin yMax:(float)yMax zMin:(float)zMin zMax:(float)zMax res:(int)res;

-(void) calculateMatrix;

-(float) surfaceAspect;

-(ofxUserGenerator*) getUserGenerator;
-(void) reset;

-(KeystoneSurface*) surface;
-(float) surfaceAspect;

-(ofxDepthGenerator*) getDepthGenerator;
-(ofxIRGenerator*) getIRGenerator;
-(ofxImageGenerator*) getColorGenerator;
-(ofxOpenNIContext*) getOpenNIContext;


@end

#endif
