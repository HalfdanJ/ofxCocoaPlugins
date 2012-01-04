#pragma once
#import "CameraInstance.h"

#define _OSX
#define _x86
#import "PvApi.h"


#define FRAMESCOUNT 1


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
}

@property (readwrite) unsigned long uid;

-(BOOL) openCamera;
-(void) closeCamera;
-(BOOL) startStreamCamera;
-(void) stopStreamCamera;

-(void) spawnThread;
@end
