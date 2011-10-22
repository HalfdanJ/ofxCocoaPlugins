#import "BlobClasses2d.h"


@implementation PersistentBlob2d
@synthesize blobs;
-(id) init{
	if([super init]){
		timeoutCounter = 0;
		centroid = new ofVec2f;
		lastcentroid = new ofVec2f;
		centroidV = new ofVec2f;
		blobs = [[NSMutableArray array] retain];
	}
	return self;
}

-(ofVec2f) getLowestPoint{
	ofVec2f low;
	Blob2d * blob;
	for(blob in blobs){
		if([blob getLowestPoint].y > low.y){
			low = [blob getLowestPoint];
		}
	}
	return low;
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

@implementation Blob2d
@synthesize cameraId, originalblob, coordWarp;

-(id)initWithMouse:(ofPoint*)point{
	if([super init]){
		blob = new ofxCvBlob();
		//floorblob = new ofxCvBlob();
		
		originalblob = new ofxCvBlob();
		//		originalblob->area = blob->area = _blob->area;
		//      originalblob->length = blob->length = _blob->length ;
		//       originalblob->boundingRect = blob->boundingRect = _blob->boundingRect;
       // floorblob->centroid = originalblob->centroid = blob->centroid = *point;
		//        originalblob->hole = blob->hole = _blob->hole;
		
		//floorblob->nPts = originalblob->nPts = blob->nPts = 30;
		for(int i=0;i<30;i++){
			float a = TWO_PI*i/30.0;
			blob->pts.push_back(ofPoint(cos(a)*0.05+point->x, sin(a)*0.05+point->y)); 
		}
		//floorblob->pts =  originalblob->pts = blob->pts ;
		
		
	} 
	return self;
}


-(ofVec2f) getLowestPoint{
	
	if(low)
		return *low;
	else {
		for(int u=0;u< [self nPts];u++){
			if(!low || [self pts][u].y > low->y){
				if(low){
					low->x = [self pts][u].x;
					low->y = [self pts][u].y;
				} else {
					low = new ofVec2f([self pts][u]);
				}
			}
		}
		return *low;
	}
	
}

-(id)initWithBlob:(ofxCvBlob*)_blob{
	if([super init]){
		blob = new ofxCvBlob();
	//	floorblob = new ofxCvBlob();
		
		originalblob = new ofxCvBlob();
		originalblob->area = blob->area = _blob->area;
        originalblob->length = blob->length = _blob->length ;
        originalblob->boundingRect = blob->boundingRect = _blob->boundingRect;
        originalblob->centroid = blob->centroid = _blob->centroid;
        originalblob->hole = blob->hole = _blob->hole;
	
        originalblob->nPts = blob->nPts = _blob->nPts;
		originalblob->pts = blob->pts = _blob->pts; 
		
	} 
	return self;
}

- (void)dealloc {
	delete blob;
	//delete floorblob;
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

/*-(void) lensCorrect{
	Lenses * lenses = GetPlugin(Lenses);
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i] = [lenses undistortPoint:(ofVec2f)blob->pts[i] fromCameraId:cameraId];
	}
	blob->centroid = [lenses undistortPoint:blob->centroid fromCameraId:cameraId];
	
	//originalblob->pts = blob->pts;
	//originalblob->centroid = blob->centroid;
	
}*/

-(void) warp{
//	CameraCalibrationObject* calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:cameraId]);
	
	//ProjectionSurfacesObject * projection = [calibrator surface];//((ProjectionSurfacesObject*)[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]);
	if(coordWarp == nil)
        return;
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i] = coordWarp->transform(blob->pts[i]);
	}
	blob->centroid = coordWarp->transform(blob->centroid);
	
	
	//Convert the blob to floor space, for better sizing 
	/*for(int i=0;i<blob->nPts;i++){
		floorblob->pts[i] = [GetPlugin(ProjectionSurfaces) convertFromProjection:blob->pts[i] surface:projection];
	}
	floorblob->centroid = [GetPlugin(ProjectionSurfaces) convertFromProjection:blob->centroid surface:projection];*/
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