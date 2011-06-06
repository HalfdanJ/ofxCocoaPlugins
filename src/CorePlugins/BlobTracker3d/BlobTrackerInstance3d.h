#pragma once

#include "Plugin.h"
#include "ofxCvMain.h"

#define NUM_SEGMENTS 6


@interface BlobTrackerInstance3d : NSObject {
    ofxCvGrayscaleImage *	grayImage[NUM_SEGMENTS];
	ofxCvGrayscaleImage * threadGrayImage[NUM_SEGMENTS];

    int distanceNear[NUM_SEGMENTS];
	int distanceFar[NUM_SEGMENTS];
    
    unsigned short * threadedPixels;
	unsigned short * threadedPixelsSorted;
    
	BOOL threadUpdateContour;
    
    
    
	ofxCvContourFinder 	* contourFinder;
	NSMutableArray * blobs;
	NSMutableArray * threadBlobs;
	NSMutableArray * persistentBlobs;

    NSThread * thread;
	pthread_mutex_t mutex;
	pthread_mutex_t drawingMutex;
    
    unsigned char pixelBuffer[640*480];
	unsigned char pixelBufferTmp[640*480];

    int threadHeatMap[1000];

    long unsigned int pidCounter;


}

@property (copy, readwrite) NSMutableArray * blobs;
@property (readonly) NSMutableArray * persistentBlobs;

-(void) setup;
-(void) update:(NSDictionary *)drawingInformation;


-(void) performBlobTracking:(id)param;




@end
