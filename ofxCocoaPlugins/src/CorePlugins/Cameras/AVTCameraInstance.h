#pragma once
#import "CameraInstance.h"

#define _OSX
#define _x86
#import "PvApi.h"


#define FRAMESCOUNT 3


typedef struct 
{
    unsigned long   UID;
    tPvHandle       Handle;
    tPvFrame        Frames[FRAMESCOUNT];
    bool            Abort;
    
} tCamera;



@interface AVTCameraInstance : CameraInstance {
    tCamera         GCamera;
    unsigned long   uid;
    
    NSThread * thread;
    NSRecursiveLock * lock;
    
    int circleIndex;
    int processIndex;
    int lastProcessedFramecount;
    
    NSString * modelName;
    NSString * ip;
    NSString * sensorSize;
    
    int exposure;
    int gain;
    
    int roiWidth, roiHeight, roiLeft, roiTop;
}

@property (readwrite) unsigned long uid;

@property (readwrite,retain) NSString * modelName;
@property (readwrite,retain) NSString * ip;
@property (readwrite,retain) NSString * sensorSize;
@property (readwrite) int exposure;
@property (readwrite) int gain;
@property (readwrite) int roiWidth;
@property (readwrite) int roiHeight;
@property (readwrite) int roiLeft;
@property (readwrite) int roiTop;

-(BOOL) openCamera;
-(void) closeCamera;
-(BOOL) startStreamCamera;
-(void) stopStreamCamera;

-(void) spawnThread;

-(void) readCameraSettings;
@end
