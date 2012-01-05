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
}

@property (readwrite) unsigned long uid;

-(BOOL) openCamera;
-(void) closeCamera;
-(BOOL) startStreamCamera;
-(void) stopStreamCamera;

-(void) spawnThread;
@end
