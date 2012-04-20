#import "Tracker.h"
#import "OSCControl.h"
#import <ofxCocoaPlugins/BlobTracker2d.h>
#import <ofxCocoaPlugins/Keystoner.h>
#import <ofxCocoaPlugins/CameraCalibrationObject.h>

@implementation Tracker

- (id)init{
    self = [super init];
    if (self) {
        controlMouse = ofVec2f(-1,-1);
        [[self addPropF:@"generatedBlobPoints"] setMinValue:1 maxValue:300];
        [[self addPropF:@"generatedBlobSize"] setMinValue:0.01 maxValue:1];
        
        [self addPropB:@"drawDebug"];
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    //    cout<<[self numberTrackers]<<endl;
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    if(PropB(@"drawDebug")){
        ApplySurface(@"Floor");
        
        int n = [self numberTrackers];
        
        
        for(int i=0; i<n;i++){
            
            switch (i) {
                case 0:
                    ofSetColor(255, 0, 0,255);
                    break;
                case 1:
                    ofSetColor(0, 255, 0,255);
                    break;
                case 2:
                    ofSetColor(0, 0, 255,255);
                    break;
                case 3:
                    ofSetColor(255, 255, 0,255);
                    break;
                case 4:
                    ofSetColor(0, 255, 255,255);
                    break;
                case 5:
                    ofSetColor(255, 0, 255,255);
                    break;
                    
                default:
                    ofSetColor(255, 255, 255,255);
                    break;
            }
            
            glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
            
            vector< ofVec2f > blob = [self trackerBlob:i];
            glBegin(GL_POLYGON);
            for(int u=0;u<blob.size();u++){
                //  ofCircle(blob[u].x, blob[u].y, 0.01);
                //   ofRect(blob[u].x*w, blob[u].y*h, 6,6);
                glVertex2f(blob[u].x, blob[u].y);
            }
            glEnd();
            glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
            
            ofVec2f centroid = [self trackerCentroid:i];
            ofVec2f feet = [self trackerFeet:i];

            ofSetColor(255,255,255);
            ofCircle(centroid.x, centroid.y, 0.003);
        
            ofSetColor(255,255,0);
            ofCircle(feet.x, feet.y, 0.003);
            
            
            
            
        }
        
        PopSurface();
    }
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{ 
    ofBackground(0,0,0);
    
    int n = [self numberTrackers];
    
    int w = ofGetWidth();
    int h = ofGetHeight();
    
    ofSetColor(100,100,100);
    [self trackerImageWithSize:CGSizeMake(400, 200)].draw(0,0,w,h);
    
    CameraCalibrationObject * calib = [[GetPlugin(BlobTracker2d) getInstance:0] calibrator];
    float aspect = [[[calib surface] aspect] floatValue];
    for(int i=0; i<n;i++){
        ofVec2f centroid = [self trackerCentroid:i];
        
        ofSetColor(255,255,255);
        ofCircle(centroid.x*w/aspect, centroid.y*h, 5);
        
        
        switch (i) {
			case 0:
				ofSetColor(255, 0, 0,255);
				break;
			case 1:
				ofSetColor(0, 255, 0,255);
				break;
			case 2:
				ofSetColor(0, 0, 255,255);
				break;
			case 3:
				ofSetColor(255, 255, 0,255);
				break;
			case 4:
				ofSetColor(0, 255, 255,255);
				break;
			case 5:
				ofSetColor(255, 0, 255,255);
				break;
				
			default:
				ofSetColor(255, 255, 255,255);
				break;
		}
        
        
        vector< ofVec2f > blob = [self trackerBlob:i];
        for(int u=0;u<blob.size();u++){
            ofCircle(blob[u].x * w / aspect, blob[u].y*h, 2);
            //   ofRect(blob[u].x*w, blob[u].y*h, 6,6);
            
        }
    }
    
    
}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    CameraCalibrationObject * calib = [[GetPlugin(BlobTracker2d) getInstance:0] calibrator];
    float aspect = [[[calib surface] aspect] floatValue];

    controlMouse = ofVec2f(aspect*x/[[self controlGlView] frame].size.width,y/[[self controlGlView] frame].size.height);    
}
-(void)controlMouseDragged:(float)x y:(float)y button:(int)button{
    CameraCalibrationObject * calib = [[GetPlugin(BlobTracker2d) getInstance:0] calibrator];
    float aspect = [[[calib surface] aspect] floatValue];

    controlMouse = ofVec2f(aspect*x/[[self controlGlView] frame].size.width,y/[[self controlGlView] frame].size.height);
}
-(void)controlMouseReleased:(float)x y:(float)y{
    controlMouse = ofVec2f(-1,-1);
}


-(int) numberTrackers{
    int num = 0;
    
    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        num += blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            num ++;
        }
    }
    
    // Camera tracker
    if(num == 0){
        num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
    }
    
    return num;
}

-(vector<ofVec2f>) trackerBlob:(int)n{
    vector<ofVec2f> v;
    
    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        if(blobs.size() > n){
            ofVec2f p = [self trackerCentroid:n];
            
            CachePropF(generatedBlobPoints);
            CachePropF(generatedBlobSize);
            
            float aStep = TWO_PI / generatedBlobPoints;
            for(int i=0;i<generatedBlobPoints;i++){
                v.push_back(ofVec2f(sin(aStep*i), cos(aStep*i))*generatedBlobSize  * (sin(aStep*i*6) + 2)+ p );
            }
            return v;
        }
        n -= blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            if(n == 0){
                CachePropF(generatedBlobPoints);
                CachePropF(generatedBlobSize);
                
                float aStep = TWO_PI / generatedBlobPoints;
                for(int i=0;i<generatedBlobPoints;i++){
                    v.push_back(ofVec2f(sin(aStep*i), cos(aStep*i))*generatedBlobSize * (sin(aStep*i*4) + 2.0) + controlMouse );
                }
                return v;
            }
            n --;            
        }
        
    }
    
    // Camera tracker
    {
        int num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
        if(num > n){
            NSArray * blobs = [[[GetPlugin(BlobTracker2d) getInstance:0] getPBlob:n] blobs];
            for(Blob2d * blob in blobs){       
                vector<ofPoint> pts = [blob pts];
                v.insert(v.end(), pts.begin(), pts.end());
/*                for(int i=0;i<pts.size();i++){
                    v.push_back(pts[i]);
                }*/
            }
            return v;
            
        }
        n -= num;
    }
    
    
    
    
    
    return v;
}

-(vector< vector<ofVec2f> >) trackerBlobVector{
    int n = [self numberTrackers];
    vector< vector<ofVec2f> > v;
    for(int i=0; i<n;i++){
        v.push_back([self trackerBlob:i]);
    }
    return v;
}

-(TrackerSource) trackerSource:(int)n{
    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        if(blobs.size() > n){
            return OSCControlSource;
        }
        n -= blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            if(n == 0){
                return MouseSource;
            }
            n --;            
        }
        
    }
    
    // Camera tracker
    {
        int num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
        if(num > n){
            return CameraSource;
        }
        n -= num;
    }
    
    return UnknownSource;

}

-(ofVec2f) trackerCentroid:(int)n{
    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        if(blobs.size() > n){
            return blobs[n];
        }
        n -= blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            if(n == 0){
                return controlMouse;
            }
            n --;            
        }
        
    }
    
    // Camera tracker
    {
        int num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
        if(num > n){
            return *[[GetPlugin(BlobTracker2d) getInstance:0] getPBlob:n]->centroid;
        }
        n -= num;
    }
    
    return ofVec2f();
}

-(vector<ofVec2f>) trackerCentroidVector{
    int n = [self numberTrackers];
    vector<ofVec2f> v;
    for(int i=0; i<n;i++){
        v.push_back([self trackerCentroid:i]);
    }
    return v;
}


-(ofVec2f) trackerFeet:(int)n{
    // OSC Control blobs
    {
        vector<ofVec2f> trackerBlob = [self trackerBlob:n];
        ofVec2f * low = nil;
        for(int u=0;u< trackerBlob.size();u++){
			if(!low || trackerBlob[u].y > low->y){
				if(low){
					low->x = trackerBlob[u].x;
					low->y = trackerBlob[u].y;
				} else {
					low = new ofVec2f(trackerBlob[u]);
				}
			}
		}
        if(low == nil)
            return ofVec2f();
        return *low;

        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        n -= blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            if(n == 0){
                return controlMouse;
            }
            n --;            
        }
        
    }
    
    // Camera tracker
    {
        int num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
        if(num > n){
            return *[[GetPlugin(BlobTracker2d) getInstance:0] getPBlob:n]->feet;
        }
        n -= num;
    }
    
    return ofVec2f();
}

-(vector<ofVec2f>) trackerFeetVector{
    int n = [self numberTrackers];
    vector<ofVec2f> v;
    for(int i=0; i<n;i++){
        v.push_back([self trackerFeet:i]);
    }
    return v;
}




-(ofxCvGrayscaleImage)trackerImageWithSize:(CGSize)res{
    ofxCvGrayscaleImage ret;
    ret.allocate(res.width,res.height);
    ret.set(0);
    
    CameraCalibrationObject * calib = [[GetPlugin(BlobTracker2d) getInstance:0] calibrator];
    
    ofPoint src[4];
    ofPoint dst[4];
    

    for(int i=0;i<4;i++){
        src[i] = [calib camHandle:i]*ofVec2f([[GetPlugin(BlobTracker2d) getInstance:0] grayDiff]->width, [[GetPlugin(BlobTracker2d) getInstance:0] grayDiff]->height);   
        dst[i] = [calib projHandle:i]/ofVec2f([[[calib surface] aspect] floatValue],1) * ofVec2f(res.width,res.height);   
    }
    
    ret.warpIntoMe(*[[GetPlugin(BlobTracker2d) getInstance:0] grayDiff], src, dst);
    
    vector< vector<ofVec2f> > trackerBlobVector = [self trackerBlobVector];
    
    for(int i=0;i<trackerBlobVector.size();i++){
        if([self trackerSource:i] != CameraSource){
            int nPoints = trackerBlobVector[i].size();
            CvPoint _cp[nPoints];
            for(int u=0;u<nPoints;u++){
                _cp[u] = cvPoint(trackerBlobVector[i][u].x*res.width/[[[calib surface] aspect] floatValue], trackerBlobVector[i][u].y*res.height);
            }
            
            CvPoint* cp = _cp;    
            cvFillPoly(ret.getCvImage(), &cp, &nPoints, 1, cvScalar(255));
        }
    }
    
    ret.flagImageChanged();
    
    
    return ret;
}

@end
