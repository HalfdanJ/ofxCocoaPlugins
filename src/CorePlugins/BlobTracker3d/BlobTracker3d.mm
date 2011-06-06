#import "BlobTracker3d.h"


//--------------------
//-- Persistent Blob --
//--------------------



@implementation PersistentBlob
@synthesize blobs;
-(id) init{
	if([super init]){
		timeoutCounter = 0;
		centroid = new ofxPoint2f;
		lastcentroid = new ofxPoint2f;
		centroidV = new ofxVec2f;
		centroidFiltered = new ofxPoint3f;
		
		centroidFilter[0] = new Filter();
		centroidFilter[1] = new Filter();					
		centroidFilter[2] = new Filter();					
		
		centroidFilter[0]->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		centroidFilter[0]->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		centroidFilter[1]->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		centroidFilter[1]->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		centroidFilter[2]->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		centroidFilter[2]->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		blobs = [[NSMutableArray array] retain];
		
	}
	return self;
}

-(ofxPoint2f) getLowestPoint{
	ofxPoint2f low;
	Blob * blob;
	for(blob in blobs){
		if([blob getLowestPoint].y > low.y){
			low = [blob getLowestPoint];
		}
	}
	return low;
}

-(ofxPoint3f) centroidFiltered{
	//return ofxPoint2f(centroidFiltered[0], centroidFiltered[1]);
	return *centroidFiltered;
}
-(void) dealloc {
	delete centroid;
	delete lastcentroid;
	delete centroidV;
	[blobs removeAllObjects];
	[blobs release];
	[super dealloc];
}

@end


//--------------------
//-- Blob --
//--------------------

@implementation Blob
@synthesize cameraId, originalblob, surfaceBlob, segment, avgDepth;

-(id)initWithMouse:(ofPoint*)point{
	if([super init]){
		blob = new ofxCvBlob();
		surfaceBlob = new ofxCvBlob();
		
		originalblob = new ofxCvBlob();
		//		originalblob->area = blob->area = _blob->area;
		//      originalblob->length = blob->length = _blob->length ;
		//       originalblob->boundingRect = blob->boundingRect = _blob->boundingRect;
        surfaceBlob->centroid = originalblob->centroid = blob->centroid = *point;
		//        originalblob->hole = blob->hole = _blob->hole;
		
		surfaceBlob->nPts = originalblob->nPts = blob->nPts = 30;
		for(int i=0;i<30;i++){
			float a = TWO_PI*i/30.0;
			blob->pts.push_back(ofPoint(cos(a)*0.05+point->x, sin(a)*0.05+point->y)); 
		}
		surfaceBlob->pts =  originalblob->pts = blob->pts ;
		
		
	} 
	return self;
}


-(ofxPoint2f) getLowestPoint{
	
	if(low)
		return *low;
	else {
		for(int u=0;u< [self nPts];u++){
			if(!low || [self pts][u].y > low->y){
				if(low){
					low->x = [self pts][u].x;
					low->y = [self pts][u].y;
				} else {
					low = new ofxPoint2f([self pts][u]);
				}
			}
		}
		return *low;
	}
	
}

-(id)initWithBlob:(ofxCvBlob*)_blob{
	if([super init]){
		blob = new ofxCvBlob();
		surfaceBlob = new ofxCvBlob();
		
		originalblob = new ofxCvBlob();
		originalblob->area = blob->area = _blob->area;
        originalblob->length = blob->length = _blob->length ;
        originalblob->boundingRect = blob->boundingRect = _blob->boundingRect;
        originalblob->centroid = blob->centroid = _blob->centroid;
        originalblob->hole = blob->hole = _blob->hole;
		
		surfaceBlob->nPts = originalblob->nPts = blob->nPts = _blob->nPts;
		surfaceBlob->pts =  originalblob->pts = blob->pts = _blob->pts; 
		
	} 
	return self;
}

- (void)dealloc {
	delete blob;
	delete surfaceBlob;
	delete originalblob;
    [super dealloc];
}

-(void) normalize:(int)w height:(int)h{
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i].x /= (float)w;
		blob->pts[i].y /= (float)h;
	}
	blob->area /= (float)w*h;
	blob->centroid.x /=(float) w;
	blob->centroid.y /= (float)h;
	blob->boundingRect.width /= (float)w; 
	blob->boundingRect.height /= (float)h; 
	blob->boundingRect.x /= (float)w; 
	blob->boundingRect.y /= (float)h; 
	
	originalblob->pts = blob->pts;
	originalblob->area = blob->area;
	originalblob->centroid = blob->centroid;
	originalblob->boundingRect = blob->boundingRect;
}

-(vector <ofPoint>)pts{
	return blob->pts;
}
-(int)nPts{
	return blob->nPts;	
}
-(ofPoint)centroid{
	return blob->centroid;		
}
-(float) area{
	return blob->area;		
}
-(float)length{
	return blob->length;		
}
-(ofRectangle) boundingRect{
	return blob->boundingRect;	
}
-(BOOL) hole{
	return blob->hole;		
}

@end




//--------------------
//-- BlobTracker3d --
//--------------------


@implementation BlobTracker3d

@end
