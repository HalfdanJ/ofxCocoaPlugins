#pragma once

#include <ofxCocoaPlugins/Plugin.h>
#include <ofxCocoaPlugins/BlobClasses2d.h>
#import <ofxCocoaPlugins/CameraCalibration.h>

#import "ofxOpenCv.h"
#import "ofxCvOpticalFlowLK.h"

class ofxQtVideoSaver;
@class QTKitMovieRenderer;

enum SubtractionModes {
    SUBTRACTION_DIFF,
    SUBTRACTION_LIGHTER,
    SUBTRACTION_DARKER
    };

@interface BlobTrackerInstance2d : NSObject {    
    NSView *view;
    NSString * name;
    NSMutableDictionary * properties;
    
    NSButton * learnBackgroundButton;
    IBOutlet NSButton * drawDebugButton;

    NSMutableArray * persistentBlobs;
	NSMutableArray * blobs;
    long unsigned int pidCounter;
    
    float maskLeft, maskRight, maskTop, maskBottom;
    
    id cameraInstance;
    int trackerNumber;
    int cw, ch;
    long long frameNum;
    
    ofxCvGrayscaleImage *	grayImage; //Incomming image
    ofxCvGrayscaleImage *	grayImageBlured; //Blurred input image
	ofxCvGrayscaleImage *	grayBg; //Background image for background subtraction
    ofxCvGrayscaleImage *	grayDiff; //Background subtracted image
    
    ofxCvGrayscaleImage * mask; //Temp image for masking
    
    ofxCvGrayscaleImage * threadGrayDiff; //Thread backgroundsubtracted image
	ofxCvGrayscaleImage * threadGrayImage; //Thread input image
    ofxCvGrayscaleImage * threadGrayImageLastFrame; //Image from last frame

    //Contour finder (Blob tracker)
    BOOL threadUpdateContour;
	ofxCvContourFinder 	* contourFinder;
    
    //Optical flow
    BOOL threadUpdateOpticalFlow;
    ofxCvOpticalFlowLK * opticalFlow;
    int opticalFlowW, opticalFlowH;
    ofVec2f * opticalFlowFieldCalibrated;
    ofVec2f * threadOpticalFlowFieldCalibrated;
    int _opticalFlowSize;
    
    //Forces loading from disk
    BOOL loadBackgroundNow;

    //Background thread & mutex
    NSThread * thread;
	pthread_mutex_t mutex;

    //Calibrator for masking
	CameraCalibrationObject * calibrator;
    
    
    BOOL live;
    
    ofxQtVideoSaver		*saver;
	BOOL recording;
    QTKitMovieRenderer * videoPlayer;
    NSMutableArray * movies;
	BOOL loadMoviePlease;
	NSString * loadMovieString;
	float millisSinceLastMovieEvent;
    int numFiles;
	unsigned char* pixels;
	unsigned char* rgbTmpPixels;

    IBOutlet NSPopUpButton *moviePopUp;
    IBOutlet NSButton *recordButton;
    
    ofPoint recordingSurfaceCorners[4];
}

@property (assign)      IBOutlet NSView *view;
@property (readonly)    NSString * name;
@property (retain)      NSMutableDictionary * properties;
@property (assign)      id cameraInstance;

@property (readonly)    ofxCvGrayscaleImage *	grayDiff;
@property (readonly)    ofxCvGrayscaleImage *	grayBg;
@property (assign)      IBOutlet NSButton * learnBackgroundButton;

@property (readwrite)   int trackerNumber;
@property (readwrite, retain) CameraCalibrationObject * calibrator;
@property (readwrite)   float maskLeft;
@property (readwrite)   float maskRight;
@property (readwrite)   float maskBottom;
@property (readwrite)   float maskTop;

@property (readonly)    ofVec2f * opticalFlowFieldCalibrated;
@property (readonly)    int opticalFlowW;
@property (readonly)    int opticalFlowH;
@property (readwrite)   int opticalFlowSize;

- (IBAction)setMovieFile:(id)sender;
- (IBAction)toggleRecord:(id)sender;

-(void) setup;
-(void) update:(NSDictionary *)drawingInformation;

-(void) startBackgroundThread:(id)param;

-(void) drawInput:(NSRect)rect;
-(void) drawBackground:(NSRect)rect;
-(void) drawDifference:(NSRect)rect;
-(void) drawBlobs:(NSRect)rect warped:(BOOL)warp;
-(void) drawSurfaceMask:(NSRect)rect;

-(void) getSurfaceMaskCorners:(ofPoint*)point clamped:(BOOL)clamp;
-(PersistentBlob2d*) getPBlob:(int)num;
-(int) numPBlobs;

-(BOOL) isKinect;

-(BOOL) drawDebug;

-(void) saveBackground;
-(void) loadBackground;
-(void) updateMovieList;

@end
