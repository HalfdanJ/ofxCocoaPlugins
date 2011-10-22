#pragma once

#include "Plugin.h"


#include "ofVectorMath.h"
#include "ofxCvMain.h"
#include "Filter.h"

//-----------------------------------------
//------- PersistentBlob
//-----------------------------------------

@interface PersistentBlob : NSObject
{
@public
	long unsigned int pid;
	ofVec2f * centroid;
	ofVec2f * lastcentroid;
	ofVec2f   * centroidV;
	
	ofxPoint3f * centroidFiltered;
    
	Filter * centroidFilter[3];
	
	int timeoutCounter;
	NSMutableArray * blobs;
	long age;
	
}
@property (assign) NSMutableArray * blobs;

-(ofVec2f) getLowestPoint;
-(ofxPoint3f) centroidFiltered;
-(void) dealloc;

@end



//-----------------------------------------
//------- Blob
//-----------------------------------------


@interface Blob : NSObject
{
	int cameraId;
	ofxCvBlob * blob;
	ofxCvBlob * originalblob;
	ofxCvBlob * surfaceBlob;
	ofVec2f * low;
	int segment;
	
	int avgDepth;
@public
	CvSeq * cvSeq; 
}
@property (readwrite) int cameraId;
@property (readonly) ofxCvBlob * originalblob;
@property (readonly) ofxCvBlob * surfaceBlob;
@property (readwrite) int segment;
@property (readwrite) int avgDepth;

-(void) normalize:(int)w height:(int)h;
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




//-----------------------------------------
//------- BlobTracker3d plugin
//-----------------------------------------

@interface BlobTracker3d : ofPlugin {
    

}

@end
