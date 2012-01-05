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
    
    int exposure;
    int gain;
}

@property (readwrite) unsigned long uid;

@property (readwrite,retain) NSString * modelName;
@property (readwrite,retain) NSString * ip;
@property (readwrite) int exposure;
@property (readwrite) int gain;

-(BOOL) openCamera;
-(void) closeCamera;
-(BOOL) startStreamCamera;
-(void) stopStreamCamera;

-(void) spawnThread;

-(void) readCameraSettings;
@end
