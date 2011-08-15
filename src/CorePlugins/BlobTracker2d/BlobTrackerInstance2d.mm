//
//  BlobTrackerInstance2d.m
//  SeMinSkygge
//
//  Created by Se Min Skygge on 07/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlobTrackerInstance2d.h"
#import "KinectInstance.h"

@implementation BlobTrackerInstance2d
@synthesize view, name, properties, cameraInstance, trackerNumber, grayDiff, grayBg;

- (id)init
{
    self = [super init];
    if (self) {
        cw = 640;
		ch = 480;
		
		thread = [[NSThread alloc] initWithTarget:self
										 selector:@selector(performBlobTracking:)
										   object:nil];
        pthread_mutex_init(&mutex, NULL);
        threadUpdateContour = NO;
		loadBackgroundNow = NO;
        
        persistentBlobs = [[NSMutableArray array] retain];
		blobs = [[NSMutableArray array] retain];
		pidCounter = 0;
        
        properties = [NSMutableDictionary dictionary];
        [properties setObject:[NSNumber numberWithFloat:5.0] forKey:@"persistentDistance"];
        [properties setObject:[NSNumber numberWithFloat:1] forKey:@"blur"];
        [properties setObject:[NSNumber numberWithFloat:100] forKey:@"threshold"];
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) setup{
    live = YES;
    
    grayImage = new ofxCvGrayscaleImage();
	grayImageBlured = new ofxCvGrayscaleImage();		
	//grayBgMask = new ofxCvGrayscaleImage();		
	grayBg = new ofxCvGrayscaleImage();
	grayDiff = new ofxCvGrayscaleImage();
    
    threadGrayDiff = new ofxCvGrayscaleImage();
	threadGrayImage = new ofxCvGrayscaleImage();
    
    grayImageBlured->allocate(cw,ch);
	grayImage->allocate(cw,ch);
	grayBg->allocate(cw,ch);
	grayDiff->allocate(cw,ch);	
    
    threadGrayDiff->allocate(cw,ch);
	threadGrayImage->allocate(cw,ch);
    
    contourFinder = new ofxCvContourFinder();
    
    [thread start];
    
    loadBackgroundNow = YES;
    
    //videoPlayer = new videoplayerWrapper();
    // dispatch_async(dispatch_get_main_queue(), ^{
    videoPlayer = [[QTKitMovieRenderer alloc] init];
    // });
	//videoPlayer->videoPlayer.setUseTexture(false);
	
	movies = [[NSMutableArray array] retain];
	[self updateMovieList];
	millisSinceLastMovieEvent = 0;
    
    pixels = new unsigned char[cw * ch];
	memset(pixels, 0, cw*ch);
    rgbTmpPixels = new unsigned char[cw * ch*3];
	memset(rgbTmpPixels, 0, cw*ch*3);
    
    saver = new ofxQtVideoSaver();
	saver->setCodecQualityLevel(OF_QT_SAVER_CODEC_QUALITY_NORMAL);
	recording = NO;
    
}


-(void) update:(NSDictionary *)drawingInformation{
    BOOL update = YES;
    
    if(live){       
        if(loadBackgroundNow){
            loadBackgroundNow= NO;
            [self loadBackground];	
        }
        if([self isKinect]){
            KinectInstance * kinect = cameraInstance;
            if(![kinect kinectConnected]){
                update = NO;
            }
        }
        if(update){
            if([self isKinect]){
                KinectInstance * kinect = cameraInstance;
                if([kinect kinectConnected]){
                    [kinect getIRGenerator]->generateTexture();
                    grayImage->setFromPixels([kinect getIRGenerator]->image_pixels, 640, 480);
                }
            }
            
            //Blur
            *grayImageBlured = *grayImage;            
            int blur = [[properties valueForKey:@"blur"] intValue];
            if(blur % 2 == 0) blur += 1;
            
            grayImageBlured->blur(blur);
            
            
            if ([learnBackgroundButton state] == NSOnState){            
                NSLog(@"Tracker %i Learn Background", trackerNumber);
                *grayBg = *grayImageBlured;
                [self saveBackground];
                [learnBackgroundButton setState:NSOffState];
            }  
            
            //Difference
            grayDiff->absDiff(*grayBg, *grayImageBlured);
            
            ofPoint maskPoints[4];
            [self getSurfaceMaskCorners:maskPoints clamped:NO];
            
            
            int nPoints = 4;
            CvPoint _cp[4]= {{0,0}, {640,0},{maskPoints[1].x,maskPoints[1].y},{maskPoints[0].x,maskPoints[0].y}};			
            CvPoint* cp = _cp; 
            cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0,0,0,10));
            
            CvPoint _cp2[4] = {{640,0}, {640,480},{maskPoints[2].x,maskPoints[2].y},{maskPoints[1].x,maskPoints[1].y}};			
            cp = _cp2; 
            cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0));
            
            CvPoint _cp3[4] = {{640,480}, {0,480},{maskPoints[3].x,maskPoints[3].y},{maskPoints[2].x,maskPoints[2].y}};			
            cp = _cp3; 
            cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0));
            
            CvPoint _cp4[4] = {{0,480}, {0,0},{maskPoints[0].x,maskPoints[0].y},{maskPoints[3].x,maskPoints[3].y}};			
            cp = _cp4; 
            cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0));
            grayDiff->flagImageChanged();
            
            grayDiff->threshold([[properties valueForKey:@"threshold"] intValue]);
            
        }
        
        
        if([recordButton state] == NSOnState){
            for(int i=0;i<cw*ch*3;i+=3){
                rgbTmpPixels[i] =  grayDiff->getPixels()[i/3];
                rgbTmpPixels[i+1] = grayDiff->getPixels()[i/3];
                rgbTmpPixels[i+2] = grayDiff->getPixels()[i/3];
            }
            saver->addFrame(rgbTmpPixels, 1.0f / ofGetFrameRate()); 	
            if(!recording){
                NSString * file = [[NSString stringWithFormat:@"~/Movies/Recordings%i/tracker_recording_%i.mov",trackerNumber,numFiles] stringByExpandingTildeInPath];
                saver->setup(640,480,[file cString]);	
            }
            recording = YES;
        } else if(recording){
            recording = NO;
            saver->finishMovie();	
            
            NSString * path = [[NSString stringWithFormat:@"~/Movies/Recordings%i/",trackerNumber] stringByExpandingTildeInPath];
            NSString * metaName = [NSString stringWithFormat:@"tracker_recording_%i",numFiles];
            
            [self saveRecordingMetadataToDisk:path name:metaName];
            numFiles ++;
            [self updateMovieList];
        }		
    } else {
        //not live
        if(loadMoviePlease){
			[self loadMovie:loadMovieString];
			loadMoviePlease = NO;
		}
        //	videoPlayer->videoPlayer.idleMovie();
        const CVTimeStamp * time;
        [[drawingInformation objectForKey:@"outputTime"] getValue:&time];	
        
        BOOL isFrameNew = [videoPlayer update:time];
        //          BOOL isFrameNew = NO;
        //		if(videoPlayer->videoPlayer.isFrameNew()){			
        if(isFrameNew){			
            [videoPlayer pixels:pixels format:GL_LUMINANCE];
            grayDiff->setFromPixels(pixels, 640, 480);
		} else {
            update = NO;
        }
    }
    
    
    if(update && [activeButton state]){
        pthread_mutex_lock(&mutex);
        *threadGrayImage = *grayImage;
        *threadGrayDiff = *grayDiff;
        threadUpdateContour = YES;
        
        PersistentBlob2d * pblob;		
        
        //Clear blobs
        for(pblob in persistentBlobs){
            ofxPoint2f p = pblob->centroid - pblob->lastcentroid;
            pblob->centroidV->x = p.x;
            pblob->centroidV->y = p.y;
            pblob->lastcentroid = pblob->centroid ;
            [pblob->blobs removeAllObjects];
        }
        
        
        
        [blobs removeAllObjects];
        {
            //if(!mouseEvent){
            
            for(int i=0;i<contourFinder->nBlobs;i++){
                ofxCvBlob * blob = &contourFinder->blobs[i];
                Blob2d * blobObj = [[[Blob2d alloc] initWithBlob:blob] autorelease];
                if([self isKinect]){
                    KinectInstance * kinect = cameraInstance;
                    [blobObj setCoordWarp:[kinect coordWarper]];
                }
                
                [blobObj setCameraId:trackerNumber];
                //  [blobObj lensCorrect];
                [blobObj normalize:cw height:ch];
                [blobObj warp];
                [blobs addObject:blobObj];
                
            }
        } /*else {
           Blob * blobObj = [[[Blob alloc] initWithMouse:mousePosition] autorelease];
           [blobObj setCameraId:trackerNumber];
           //	[blobObj normalize:cw height:ch];
           
           //					[blobObj warp];
           [blobs addObject:blobObj];
           
           }*/
        
        
        pthread_mutex_unlock(&mutex);
        
        float persistentDistance = [[properties valueForKey:@"persistentDistance"]floatValue];
        for(Blob2d * blob in blobs){
            bool blobFound = false;
            float shortestDist = 0;
            int bestId = -1;
            KeystoneSurface * surface;
            if([self isKinect]){
                KinectInstance * kinect = cameraInstance;
                surface = [kinect surface];
            }
            
            ofxPoint2f centroid = ofxPoint2f([blob centroid].x, [blob centroid].y);
            //				ofxPoint2f floorCentroid = [GetPlugin(ProjectionSurfaces) convertPoint:centroid fromProjection:"Front" surface:"Floor"];
            ofxPoint2f floorCentroid = [surface convertFromProjection:centroid];
            
            //Går igennem alle grupper for at finde den nærmeste gruppe som blobben kan tilhøre
            //Magisk høj dist: 0.3
            
            /*for(int u=0;u<[persistentBlobs count];u++){
             //Giv forrang til døde persistent blobs
             if(((PersistentBlob*)[persistentBlobs objectAtIndex:u])->timeoutCounter > 5){
             float dist = centroid.distance(*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid);
             if(dist < [persistentSlider floatValue]*0.5 && (dist < shortestDist || bestId == -1)){
             bestId = u;
             shortestDist = dist;
             blobFound = true;
             }
             }
             }*/
            if(!blobFound){						
                for(int u=0;u<[persistentBlobs count];u++){
                    //						ofxPoint2f centroidPoint = [GetPlugin(ProjectionSurfaces) convertPoint:*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid fromProjection:"Front" surface:"Floor"];
                    
                    ofxPoint2f centroidPoint = [surface convertFromProjection:*((PersistentBlob2d*)[persistentBlobs objectAtIndex:u])->centroid];
                    float dist = floorCentroid.distance(centroidPoint);
                    if(dist < persistentDistance && (dist < shortestDist || bestId == -1)){
                        bestId = u;
                        shortestDist = dist;
                        blobFound = true;
                    }
                }
            }
            
            if(blobFound){	
                //    [currrentPblobCounter setIntValue:[currrentPblobCounter intValue] +1];
                
                PersistentBlob2d * bestBlob = ((PersistentBlob2d*)[persistentBlobs objectAtIndex:bestId]);
                
                
                //Fandt en gruppe som den her blob kan tilhøre.. Pusher blobben ind
                bestBlob->timeoutCounter = 0;
                [bestBlob->blobs addObject:blob];
                
                //regner centroid ud fra alle blobs i den
                bestBlob->centroid->set(0, 0);
                for(int g=0;g<[bestBlob->blobs count];g++){
                    ofxPoint2f blobCentroid = ofxPoint2f([[bestBlob->blobs objectAtIndex:g] centroid].x, [[bestBlob->blobs objectAtIndex:g] centroid].y);
                    *bestBlob->centroid += blobCentroid;					
                }
                *bestBlob->centroid /= (float)[bestBlob->blobs count];
            }
            
            if(!blobFound){
                //Der var ingen gruppe til den her blob, så vi laver en
                PersistentBlob2d * newB = [[PersistentBlob2d alloc] init];
                [newB->blobs addObject:blob];
                *newB->centroid = centroid;
                newB->pid = pidCounter++;
                [persistentBlobs addObject:newB];		
                
                //       [newestId setIntValue:pidCounter];
            }
        }		
        
        //Delete all the old pblobs
        for(int i=0; i< [persistentBlobs count] ; i++){
            PersistentBlob2d * blob = [persistentBlobs objectAtIndex:i];
            blob->timeoutCounter ++;
            if(blob->timeoutCounter > 10){
                [persistentBlobs removeObject:blob];
            }			
        }
        
    }
    
}

-(void)setCameraInstance:(id)_cameraInstance{
    cameraInstance = _cameraInstance;
    
    if([self isKinect]){
        KinectInstance * kinect = cameraInstance;
        name = [NSString stringWithFormat:@"Kinect %i",[kinect kinectNumber]];
    }
}


-(void) drawInput:(NSRect)rect{
    /*if([self isKinect]){
     KinectInstance * kinect = cameraInstance;
     [kinect getIRGenerator]->draw(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
     }*/
    grayImage->draw(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

-(void) drawBackground:(NSRect)rect{
    grayBg->draw(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

-(void) drawDifference:(NSRect)rect{
    grayDiff->draw(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);    
}

-(void) drawBlobs:(NSRect)rect warped:(BOOL)warp{
	for(PersistentBlob2d * blob in persistentBlobs){
		int i=blob->pid%5;
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
        
		for(Blob2d * b in [blob blobs]){
			glBegin(GL_LINE_STRIP);
            for(int i=0;i<[b nPts];i++){
				ofxVec2f p = [b pts][i];
				//				p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" surface:"Floor"];

                if(!warp)
                	p = [b originalblob]->pts[i];
				glVertex2f(rect.origin.x+p.x*rect.size.width, rect.origin.y+p.y*rect.size.height);
				//glVertex2f(w*3+p.x/640.0*w, p.y/480.0*h);
				//cout<<p.x<<"  "<<p.y<<endl;
				
			}
			glEnd();
		}
	}
	
    
}

-(void) drawSurfaceMask:(NSRect)rect{
    BOOL doDraw = YES;
    if([self isKinect]){
        KinectInstance * kinect = cameraInstance;
        if(![kinect kinectConnected])
            doDraw = NO;
    }
    
    if(doDraw){
        ofPoint points[4];
        [self getSurfaceMaskCorners:points clamped:YES];
        
        glPushMatrix();{
            glTranslated(rect.origin.x, rect.origin.y, 0);
            glScaled(rect.size.width/640.0, rect.size.height/480.0,1);
            ofEnableAlphaBlending();
            ofSetColor(180,0,0,50);
            glBegin(GL_QUAD_STRIP);{
                glVertex2f(0, 0);       glVertex2f(points[0].x, points[0].y);
                glVertex2f(640, 0);     glVertex2f(points[1].x, points[1].y);
                glVertex2f(640, 480);   glVertex2f(points[2].x, points[2].y);
                glVertex2f(0, 480);     glVertex2f(points[3].x, points[3].y);
                glVertex2f(0, 0);       glVertex2f(points[0].x, points[0].y);
            }glEnd();  
            
            ofSetColor(255,0,0,120);
            glLineWidth(2);
            glBegin(GL_LINE_STRIP);{
                glVertex2f(points[0].x, points[0].y);
                glVertex2f(points[1].x, points[1].y);
                glVertex2f(points[2].x, points[2].y);
                glVertex2f(points[3].x, points[3].y);
                glVertex2f(points[0].x, points[0].y);
            }glEnd();
            glLineWidth(1);
        }glPopMatrix();
        ofSetColor(255,255,255);
    }
}


-(void) getSurfaceMaskCorners:(ofPoint*)points clamped:(BOOL)clamp{
    if(live){
    ofPoint corners[4];
    ofPoint realCorners[4];
    
    float dist[4];
    for(int i=0;i<4;i++){
        dist[i] = -1;
    }
    if([self isKinect]){
        realCorners[0] = ofPoint(0,0);
        realCorners[1] = ofPoint(640,0);
        realCorners[2] = ofPoint(640,480);
        realCorners[3] = ofPoint(0,480);
        
        KinectInstance * kinect = cameraInstance;
        corners[0] = [kinect surfaceCorner:0];
        corners[1] = [kinect surfaceCorner:1];
        corners[2] = [kinect surfaceCorner:3];
        corners[3] = [kinect surfaceCorner:2];
        for(int i=0;i<4;i++){
            if(clamp){
                corners[i].x = ofClamp(corners[i].x,0,640);
                corners[i].y = ofClamp(corners[i].y,0,480);
            }
        }
        for(int i=0;i<4;i++){
            for(int j=0;j<4;j++){
                float d = ofDistSquared(corners[j].x, corners[j].y, realCorners[i].x, realCorners[i].y);
                if(dist[i] == -1 || dist[i] > d){
                    dist[i] = d;
                    points[i] = corners[j];
                }
            }
        }
    } 
    } else {
        for(int i=0;i<4;i++){
            points[i] = ofPoint(recordingSurfaceCorners[i]);
        }
    }
}

-(BOOL) isKinect{
    if([cameraInstance isKindOfClass:[KinectInstance class]])
        return YES;  
    return NO;
}


-(void) saveBackground{
	//	ofLog(OF_LOG_NOTICE, "<<<<<<<< gemmer billede " + ofToString(cameraId));
    NSString * basePath = [[NSString stringWithFormat:@"~/Pictures/Background/blobTracker%iBackground.png",trackerNumber] stringByExpandingTildeInPath];
    NSLog(@"basePath %@",basePath);
	ofImage saveImg;
	saveImg.allocate(grayBg->getWidth(), grayBg->getHeight(), OF_IMAGE_GRAYSCALE);
	saveImg.setFromPixels(grayBg->getPixels(), grayBg->getWidth(), grayBg->getHeight(), false);
	saveImg.saveImage([basePath cStringUsingEncoding:NSUTF8StringEncoding]);	
}

-(void) loadBackground{
    NSString * basePath = [[NSString stringWithFormat:@"~/Pictures/Background/blobTracker%iBackground.png",trackerNumber] stringByExpandingTildeInPath];
    
	ofImage loadImg;
	if (loadImg.loadImage([basePath cStringUsingEncoding:NSUTF8StringEncoding])) {
		grayBg->setFromPixels(loadImg.getPixels(), loadImg.getWidth(), loadImg.getHeight());
        grayBg->draw(0, 0,0,0);
		//		return true;
	} else {
		//		return false;
	}
}


-(void) performBlobTracking:(id)param{
	while(1){
		
		pthread_mutex_lock(&mutex);			
		
		if(threadUpdateContour){
			contourFinder->findContours(*threadGrayDiff, 20, (cw*ch)/3, 10, false, true);	
			threadUpdateContour = false;			
			
			/*	int l = -1;
			 if(contourFinder->nBlobs > 0){
			 for(int i=0;i<contourFinder->blobs[0]->
			 
			 }
			 */
            
            
		}
		
		/*if(threadUpdateOpticalFlow){
         opticalFlow->calc(*threadFlowLastImage, *threadFlowImage, 11);
         threadUpdateOpticalFlow = false;			
         }
         */
        
        
		pthread_mutex_unlock(&mutex);
		
		[NSThread sleepForTimeInterval:0.03];
	}
	
}


-(PersistentBlob2d*) getPBlob:(int)num{
    if(num >= 0 && num < [persistentBlobs count]){
        return [persistentBlobs objectAtIndex:num];
    }
    return nil;
}



-(void) updateMovieList{    
    [moviePopUp removeAllItems];
    [moviePopUp addItemWithTitle:@"- Live -"];
    
	[movies removeAllObjects];
	
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * fileNameFromDefaults = [userDefaults stringForKey:[NSString stringWithFormat:@"camera.%i.movie.fileName",trackerNumber]];
	BOOL foundFileNameFromDefaults = NO;
	NSFileManager * filesystem = [NSFileManager defaultManager];
	//NSLog([NSString stringWithCString:ofToDataPath("recordedMovies/", true).c_str()]);
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"~/Movies/Recordings%i/",trackerNumber] stringByExpandingTildeInPath]];
	NSArray * content = [filesystem contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray array] options:0 error:&error];
	//NSLog(@"Found %d files",[content count]);
	numFiles = [content count];
	NSURL * item;
	int i=0;
	for(item in content){
		i++;
		NSNumber *isFile = nil;
		[item getResourceValue:&isFile forKey:NSURLIsRegularFileKey error:NULL];
		
		NSNumber * isHidden = nil;
		[item getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:NULL];
		
		if ([isFile boolValue] && ![isHidden boolValue]) {
			NSString *fileName = nil;
			[item getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
			
			//NSLog(fileName);
			[moviePopUp addItemWithTitle:fileName];
			[movies addObject:item];
			if(loadMoviePlease == NO && live == NO){
				loadMovieString = [NSString stringWithString:fileName];
				loadMoviePlease = YES;
			}
			//NSLog(fileNameFromDefaults);
			if ([fileNameFromDefaults compare:loadMovieString]) {
				NSLog(@"found");
				foundFileNameFromDefaults = YES;
			}
		}
	}
	if (foundFileNameFromDefaults && ![fileNameFromDefaults isEqualToString:@"live"]){
        
        loadMovieString = fileNameFromDefaults;
		[moviePopUp selectItemWithTitle:loadMovieString];
        live = NO;
        loadMoviePlease = YES;
	} else {
        live = YES;
        [moviePopUp selectItemAtIndex:0];
        
    }
}

-(void) loadMovie:(NSString*) _name{
	//videoPlayer = new videoplayerWrapper();
	NSString * file = [[NSString stringWithFormat:@"~/Movies/Recordings%i/%@",trackerNumber,_name] stringByExpandingTildeInPath];
    //	if(videoPlayer->videoPlayer.loadMovie([file cString] )){
    if([videoPlayer loadMovie:file allowTexture:NO allowPixels:YES]){
        //[videoPlayer setRate:1.0];
        //  [videoPlayer setLoops:YES];
		//	videoPlayer->setLoopState(OF_LOOP_NORMAL);
		cout<<"Loaded: "<<	[file cString]<<endl;
        [self loadRecordinMetadataFromDisk:[[NSString stringWithFormat:@"~/Movies/Recordings%i/",trackerNumber] stringByExpandingTildeInPath] name:[_name stringByDeletingPathExtension]];  
        //        videoPlayer->videoPlayer.play();
        //	[[[GetPlugin(Tracking) trackerNumber:camNumber] learnBackgroundButton] setState:NSOnState];
	} else {
		cout<<"Could not load: "<<	[file cString]<<endl;
	}
}

-(IBAction) setMovieFile:(id)sender{	
    if([sender indexOfSelectedItem] == 0){
        live = YES;
        
        //     videoPlayer->videoPlayer.close();
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@"live" forKey:[NSString stringWithFormat:@"camera.%i.movie.fileName",trackerNumber]];
        
        [recordButton setEnabled:YES];
        
    } else {
        live = NO;
        loadMovieString = [NSString stringWithString:[sender titleOfSelectedItem]];
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:loadMovieString forKey:[NSString stringWithFormat:@"camera.%i.movie.fileName",trackerNumber]];
        loadMoviePlease = YES;	
        [recordButton setEnabled:NO];
        
    }
}

- (IBAction)toggleRecord:(id)sender {
}

- (void) saveRecordingMetadataToDisk:(NSString*)path name:(NSString*)_name{
    NSLog(@"Save file metadata: %@",path);
    
    ofPoint points[4];
    [self getSurfaceMaskCorners:points clamped:NO];
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:4];
    for(int i=0;i<4;i++){
        [arr addObject:[NSNumber numberWithFloat:points[i].x]];
        [arr addObject:[NSNumber numberWithFloat:points[i].y]];
    }
    
    
    NSMutableData * data = [[NSMutableData data] retain];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat: NSPropertyListXMLFormat_v1_0];
    
    [archiver encodeObject:arr forKey:@"corners"];
    [archiver encodeObject:[NSDate date] forKey:@"time"];
    [archiver finishEncoding];
    
    [data writeToFile:[NSString stringWithFormat:@"%@/%@",path,_name] atomically:YES];	
    [archiver release];

    [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"icon"] forFile:[NSString stringWithFormat:@"%@/%@",path,_name] options:0];


}


- (void) loadRecordinMetadataFromDisk:(NSString*)path name:(NSString*)_name{
	NSData*	data = [[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",path,_name]];
		if(data != nil){
			NSLog(@"Load file: %@",[NSString stringWithFormat:@"%@/%@",path,_name]);
			NSKeyedUnarchiver * _unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			NSLog(@"Recording from %@",[_unarchiver decodeObjectForKey:@"time"]);

            NSArray * array = [_unarchiver decodeObjectForKey:@"corners"];
            NSLog(@"Array: %@",array);
            for(int i=0;i<4;i++){
                recordingSurfaceCorners[i] = ofPoint([[array objectAtIndex:i*2] floatValue], [[array objectAtIndex:i*2+1] floatValue]);
            }
            
			[_unarchiver finishDecoding];
			[_unarchiver release];
            
		}	
		[data release];
}

-(BOOL) drawDebug{
    return [drawDebugButton state];   

}
@end
