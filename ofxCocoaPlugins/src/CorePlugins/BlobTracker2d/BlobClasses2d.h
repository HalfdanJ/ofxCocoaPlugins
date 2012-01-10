#pragma once

#include <ofxCocoaPlugins/Plugin.h>
#import "ofxOpenCv.h"
#import <ofxCocoaPlugins/coordWarp.h>

@interface PersistentBlob2d : NSObject
{
@public
	long unsigned int pid;
	ofVec2f * centroid;
	ofVec2f * lastcentroid;
	ofVec2f   * centroidV;
	
	
	int timeoutCounter;
	NSMutableArray * blobs;
	
}
@property (assign) NSMutableArray * blobs;

-(ofVec2f) getLowestPoint;
-(void) dealloc;

@end

@interface Blob2d : NSObject
{
	int cameraId;
	ofxCvBlob * blob;
	ofxCvBlob * originalblob;
	//ofxCvBlob * floorblob;
	ofVec2f * low;
    
    coordWarping * coordWarp;
	
@public
	CvSeq * cvSeq; 
}
@property (readwrite) int cameraId;
@property (readonly) ofxCvBlob * originalblob;
@property (readonly) ofxCvBlob * floorblob;
@property (readwrite) coordWarping * coordWarp;

-(void) normalize:(int)w height:(int)h;
//-(void) lensCorrect;
-(void) warp;
-(void) dealloc;

-(id)initWithBlob:(ofxCvBlob*)_blob;
-(id)initWithMouse:(ofPoint*)point;

-(vector <ofPoint>)pts;
-(int)nPts;
-(ofPoint)centroid;
-(float) area;
-(float)length;
-(ofRectangle) boundingRect;
-(BOOL) hole;

-(ofVec2f) getLowestPoint;



@end