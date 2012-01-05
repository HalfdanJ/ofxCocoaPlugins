#import "AVTCamerasController.h"




@implementation AVTCamerasController

void static  CameraEventCB(void* context,
                   tPvInterface Interface,
                   tPvLinkEvent Event,
                   unsigned long UniqueId)
{
    switch(Event)
    {
        case ePvLinkAdd:
        {
            [(AVTCamerasController*)context cameraRecognized:UniqueId];
            break;
        }
        case ePvLinkRemove:
        {
            [(AVTCamerasController*)context cameraUnplugged:UniqueId];
            break;
        }
        default:
            break;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [self setInstances:[NSMutableArray array]];
        
        tPvErr errCode;
        
        // initialize the PvAPI
        if((errCode = PvInitialize()) != ePvErrSuccess)
            printf("PvInitialize err: %u\n", errCode);
        else
        {
            // register camera plugged in callback
            if((errCode = PvLinkCallbackRegister(CameraEventCB,ePvLinkAdd,self)) != ePvErrSuccess)
                printf("PvLinkCallbackRegister err: %u\n", errCode);
            
            // register camera unplugged callback
            if((errCode = PvLinkCallbackRegister(CameraEventCB,ePvLinkRemove,self)) != ePvErrSuccess)
                printf("PvLinkCallbackRegister err: %u\n", errCode);
            
        }
        
    }
    return self;
}

-(void) cameraRecognized:(unsigned long) uid{
    @synchronized(self)
    {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    printf("Event: camera %lu recognized\n",uid);
    
    //Look for cameras with same uid
    BOOL camFound = NO;
    for(AVTCameraInstance * instance in [self instances]){
//        AVTCameraInstance * instance = [cameraInstanceDict objectForKey:@"instance"];
        if([instance uid] == uid){
            //Found existing instance, just update status
            [instance setCamIsConnected:YES];
            camFound = YES;
            break;
        }
    }
    if(!camFound){
        //Camera not already in array, so we create one
        AVTCameraInstance * instance = [[AVTCameraInstance alloc] init];
        [instance setName:[NSString stringWithFormat:@"AVT Cam: %lu",uid]];
        [instance setUid:uid];
        [instance setCamIsConnected:YES];
        
        [self willChangeValueForKey:@"instances"];
        [[self instances] addObject:instance];
        [self didChangeValueForKey:@"instances"];
    }
    
    [pool release];
    }

}
-(void) cameraUnplugged:(unsigned long) uid{
    @synchronized(self)
    {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    printf("\nEvent: camera %lu unplugged\n",uid);
    
    //Look for cameras with same uid
    for(AVTCameraInstance * instance in [self instances]){
        if([instance uid] == uid){
            //Found existing instance, just update status
           
            [instance setCamIsConnected:NO];

            break;
        }
    }
    
    [pool release];
    }
}

@end
