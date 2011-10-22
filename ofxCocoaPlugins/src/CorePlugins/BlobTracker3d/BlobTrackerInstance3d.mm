//
//  BlobTrackerInstance3d.m
//  SeMinSkygge
//
//  Created by Se Min Skygge on 05/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlobTrackerInstance3d.h"

@implementation BlobTrackerInstance3d
@synthesize blobs, persistentBlobs;

- (id)init
{
    self = [super init];
    if (self) {
        blobs = [[NSMutableArray array] retain];
        threadBlobs = [[NSMutableArray array] retain];
        persistentBlobs = [[NSMutableArray array] retain];

    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)setup{
    thread = [[NSThread alloc] initWithTarget:self
									 selector:@selector(performBlobTracking:)
									   object:nil];
	pthread_mutex_init(&mutex, NULL);
	pthread_mutex_init(&drawingMutex, NULL);
	threadUpdateContour = NO;

    
    
	for(int i=0;i<NUM_SEGMENTS;i++){
		grayImage[i] = new ofxCvGrayscaleImage();
		threadGrayImage[i] = new ofxCvGrayscaleImage();
		
		grayImage[i]->allocate(640,480);
		threadGrayImage[i]->allocate(640,480);
	}
	
	threadedPixels = new unsigned short[640*480];
	threadedPixelsSorted = new unsigned short[640*480];
	
	contourFinder = new ofxCvContourFinder();
	
	[thread start];

}

-(void) update:(NSDictionary *)drawingInformation{
    //Blob tracking
   /* if(PropB(@"blobTracking")){
        xn::DepthMetaData dmd;
        depth.getXnDepthGenerator().GetMetaData(dmd);	
        const XnDepthPixel* pixels = dmd.Data();
        
        pthread_mutex_lock(&drawingMutex);
        pthread_mutex_lock(&mutex);
        if(!threadUpdateContour){				
            
            memcpy(threadedPixels, pixels, 640*480*sizeof(XnDepthPixel));
            
            for(int i=0;i<NUM_SEGMENTS;i++){
                *grayImage[i] = *threadGrayImage[i];
            }
            
            [self setBlobs:threadBlobs];
            
            threadUpdateContour = YES;				
        }
        
        pthread_mutex_unlock(&mutex);
        
        
        
        //Clear blobs
        for(PersistentBlob * pblob in persistentBlobs){
            ofVec2f p = pblob->centroid - pblob->lastcentroid;
            pblob->centroidV->x = p.x;
            pblob->centroidV->y = p.y;
            pblob->lastcentroid = pblob->centroid ;
            [pblob->blobs removeAllObjects];
            pblob->age ++;
        }
        
        for(Blob * blob in blobs){
            bool blobFound = false;
            float shortestDist = 0;
            int bestId = -1;
            
            ofxPoint3f centroid = ofxPoint3f([blob centroid].x*640, [blob centroid].y*480, [blob avgDepth]);
            ofxPoint3f surfaceCentroid3 = [self convertWorldToSurface:[self convertKinectToWorld:centroid]];
            ofVec2f surfaceCentroid = ofVec2f(surfaceCentroid3.x, surfaceCentroid3.z);
            
            //Går igennem alle grupper for at finde den nærmeste gruppe som blobben kan tilhøre
            //Magisk høj dist: 0.3
            
            
            if(!blobFound){						
                for(int u=0;u<[persistentBlobs count];u++){
                    //						ofVec2f centroidPoint = [GetPlugin(ProjectionSurfaces) convertPoint:*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid fromProjection:"Front" surface:"Floor"];
                    ofVec2f centroidPoint = *((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid;
                    float dist = surfaceCentroid.distance(centroidPoint);
                    if(dist < PropF(@"persistentDist") && (dist < shortestDist || bestId == -1)){
                        bestId = u;
                        shortestDist = dist;
                        blobFound = true;
                    }
                }
            }
            
            if(blobFound){	
                //					[currrentPblobCounter setIntValue:[currrentPblobCounter intValue] +1];
                
                PersistentBlob * bestBlob = ((PersistentBlob*)[persistentBlobs objectAtIndex:bestId]);
                
                //					[bestBlob->blobs removeAllObjects];
                
                //Fandt en gruppe som den her blob kan tilhøre.. Pusher blobben ind
                bestBlob->timeoutCounter = 0;
                [bestBlob->blobs addObject:blob];
                
                //regner centroid ud fra alle blobs i den
                bestBlob->centroid->set(0, 0);
                for(int g=0;g<[bestBlob->blobs count];g++){
                    ofxPoint3f kinectCentroid = ofxPoint3f([[bestBlob->blobs objectAtIndex:g] centroid].x*640, [[bestBlob->blobs objectAtIndex:g] centroid].y*480, [[bestBlob->blobs objectAtIndex:g] avgDepth]);
                    ofxPoint3f blobCentroid3 = [self convertWorldToSurface:[self convertKinectToWorld:kinectCentroid]];
                    ofVec2f blobCentroid = ofVec2f(blobCentroid3.x, blobCentroid3.z);
                    *bestBlob->centroid += blobCentroid;					
                }
                *bestBlob->centroid /= (float)[bestBlob->blobs count];
                
                ofxPoint3f kinectLowestPoint = ofxPoint3f([bestBlob getLowestPoint].x*640, [bestBlob getLowestPoint].y*480, pixels[(int)([bestBlob getLowestPoint].x*640+[bestBlob getLowestPoint].y*480*640)]);
                ofxPoint3f lowestPointSurface = [self convertWorldToSurface:[self convertKinectToWorld:kinectLowestPoint]];
                
                
                bestBlob->centroidFiltered->x = bestBlob->centroidFilter[0]->filter(bestBlob->centroid->x);
                bestBlob->centroidFiltered->y = bestBlob->centroidFilter[1]->filter(lowestPointSurface.y);
                bestBlob->centroidFiltered->y = bestBlob->centroidFilter[1]->filter(lowestPointSurface.y);
                bestBlob->centroidFiltered->y = bestBlob->centroidFilter[1]->filter(lowestPointSurface.y);
                bestBlob->centroidFiltered->z = bestBlob->centroidFilter[2]->filter(bestBlob->centroid->y);
            }
            
            if(!blobFound){
                //Der var ingen gruppe til den her blob, så vi laver en
                PersistentBlob * newB = [[PersistentBlob alloc] init];
                [newB->blobs addObject:blob];
                *newB->centroid = surfaceCentroid;
                
                ofxPoint3f kinectLowestPoint = ofxPoint3f([newB getLowestPoint].x*640, [newB getLowestPoint].y*480, pixels[(int)([newB getLowestPoint].x*640+[newB getLowestPoint].y*480*640)]);
                ofxPoint3f lowestPointSurface = [self convertWorldToSurface:[self convertKinectToWorld:kinectLowestPoint]];
                
                newB->centroidFilter[0]->setStartValue(surfaceCentroid.x);
                newB->centroidFilter[1]->setStartValue(lowestPointSurface.y);
                newB->centroidFilter[2]->setStartValue(surfaceCentroid.y);
                
                *newB->centroidFiltered = *newB->centroid;
                newB->pid = pidCounter++;
                newB->age = 0;
                [persistentBlobs addObject:newB];		
                
                //[newestId setIntValue:pidCounter];
            }
        }		
        
        //Delete all the old pblobs
        for(int i=0; i< [persistentBlobs count] ; i++){
            PersistentBlob * blob = [persistentBlobs objectAtIndex:i];
            blob->timeoutCounter ++;
            if(blob->timeoutCounter > 10){
                [persistentBlobs removeObject:blob];
            }			
        }
        
        pthread_mutex_unlock(&drawingMutex);
    }*/
}


//-----
// Blob tracking - the hard part
//-----
/*
 -(void) performBlobTracking:(id)param{
    while(1){		
        pthread_mutex_lock(&mutex);			
        
        if(threadUpdateContour){
            int count = 0;
            int lastSegment = 0;			
            
            int segmentSize = PropI(@"segmentSize");			
            int min = PropI(@"minDistance");
            int max = PropI(@"maxDistance");
            
            int ymin = PropF(@"yMin");
            int ymax = PropF(@"yMax");
            
            [threadBlobs removeAllObjects];
            
            
            
            
            
            for(int i=0;i<1000;i++){
                threadHeatMap[i] = 0;
            }
            
            for(int i=0;i<640*480;i++){	
                int index = threadedPixels[i] / 10.0;
                threadHeatMap[index] ++;
            }
            
            
            for(int i=0;i<1000;i++){
                if(i*10.0 < min || i*10.0 > max)
                    threadHeatMap[i] = 0;
            }
            
            while(count < NUM_SEGMENTS){
                if(lastSegment < 9600){
                    memset(pixelBufferTmp, 0, 640*480);
                    
                    int nearestPixel = -1;		
                    int start = ceil(lastSegment/10.0)+1;
                    for(int i=start;i<1000;i++){							
                        if(threadHeatMap[i] > 0 && (nearestPixel == -1)){
                            nearestPixel = i*10.0;
                            break;
                        }
                    }
                    
                    if(nearestPixel != -1){					
                        int c = 0;
                        //Find s - the size of the segment
                        int s = 0;						
                        if(nearestPixel > 9000){
                            s = 1000;
                        } else {							
                            int start = ceil(nearestPixel/10.0);
                            for(int i=start;i<1000;i++){							
                                if(threadHeatMap[i] > 0 && i * 10.0 <= nearestPixel + s + segmentSize){
                                    s = i*10.0 - nearestPixel;								
                                }
                            }
                        }
                        
                        if(s > 0){
                            for(int i=0;i<640*480;i++){
                                if(threadedPixels[i] >= nearestPixel && threadedPixels[i] < nearestPixel + s){
                                    pixelBufferTmp[i] = 255;
                                    c++;
                                } 
                            }	
                        }
                        lastSegment = nearestPixel+s;
                        
                        threadGrayImage[count]->setFromPixels(pixelBufferTmp,640,480);			
                        if(c > 10){
                            contourFinder->findContours(*threadGrayImage[count], 20, (640*480)/10, 10, false, true);
                            
                            for(int i=0;i<contourFinder->nBlobs;i++){
                                ofxCvBlob * blob = &contourFinder->blobs[i];
                                Blob * blobObj = [[[Blob alloc] initWithBlob:blob] autorelease];
                                [blobObj setCameraId:0];
                                [blobObj normalize:640 height:480];
                                [blobObj setSegment:count];
                                
                                float avg = 0;
                                for( int i=0;i<blob->pts.size();i++){
                                    avg += threadedPixels[int(blob->pts.at(i).y*640 + blob->pts.at(i).x)];
                                }
                                avg /= (float)blob->pts.size();
                                [blobObj setAvgDepth:avg];
                                
                                ofVec2f p = [blobObj getLowestPoint];
                                ofxPoint3f p3 = [self convertWorldToSurface:[self convertKinectToWorld:ofxPoint3f(p.x*640,p.y*480,avg)]];
                                if(p3.y > ymin && p3.y < ymax){								
                                    [threadBlobs addObject:blobObj];							
                                }
                            }
                            
                            distanceNear[count] = nearestPixel;
                            distanceFar[count] = nearestPixel + s;
                        } else {
                            count --;
                        }
                        
                    } else {
                        threadGrayImage[count]->set(0);			
                        distanceNear[count] = 0;
                    }
                }
                count ++;				
            }		
        }
        
        threadUpdateContour = false;		
        
        pthread_mutex_unlock(&mutex);
        
        [NSThread sleepForTimeInterval:0.01];
    }
}
*/

@end
