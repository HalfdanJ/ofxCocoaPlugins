#import "AVTCameraInstance.h"

@implementation AVTCameraInstance
@synthesize uid;

void FrameDoneCB(tPvFrame* pFrame)
{ 
	// if frame hasn't been cancelled, requeue frame
    /*    if(pFrame->Status != ePvErrCancelled)
     PvCaptureQueueFrame(GCamera.Handle,pFrame,FrameDoneCB); */
    //  NSLog(@"FRAME!!!!!");
}

- (id)init {
    self = [super init];
    if (self) {
        //IMPORTANT: Initialize camera structure. See tPvFrame in PvApi.h for more info.
        memset(&GCamera,0,sizeof(tCamera));
        lock = [[NSRecursiveLock alloc]init];
    }
    return self;
}

-(void)initCam{
    [super initCam];
    GCamera.Abort = NO;
    [self spawnThread];
    
}

-(void)close{
    [super close];

    while([self camIsClosing] && [self camInited]){
        sleep(1);
    }
    [self closeCamera];
    GCamera.UID = 0;

}

-(void)setCamIsConnected:(BOOL)_camIsConnected{
    [super setCamIsConnected:_camIsConnected];
    if(!_camIsConnected){
        GCamera.Abort = true;
        
        [self close];
    }
}

#pragma mark Thread
-(void) threadedFunction{
    while(![self camIsClosing] && [self camIsConnected]){
        if([self camIsIniting]){
            if(!GCamera.UID && !GCamera.Abort)
            {
                GCamera.UID = [self uid];    
                
                if([self openCamera])
                {
                    printf("Camera %lu opened\n",[self uid]);   
                    
                    // start streaming from the camera
                    if([self startStreamCamera])
                    {
                        //create a thread to display camera stats. 
                        [self setCamInited:YES];
                    }
                    else
                    {
                        //failure. signal main thread to abort
                        GCamera.Abort = true;
                    }
                
                }
                else
                {
                    //failure. signal main thread to abort
                    GCamera.Abort = true;
                }
            }  
            
            
        }
        
        if([self camInited]){
            PvCaptureWaitForFrameDone(GCamera.Handle, &(GCamera.Frames[0]), 2000);
            
            //requeue frame
            if(GCamera.Frames[0].Status != ePvErrCancelled && !GCamera.Abort && ![self camIsClosing]){
                PvCaptureQueueFrame(GCamera.Handle, &(GCamera.Frames[0]), NULL);
            }
        }
    }
    
    if([self camIsClosing]){
        [self setCamIsClosing:NO];
        //TODO Close!
    }
    
    NSLog(@"Thread stopped");
}

-(void)spawnThread{
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadedFunction) object:nil];
    [thread start];
}


#pragma mark PvAPI

-(BOOL) openCamera{
    // open camera, allocate memory
    // return value: true == success, false == fail
    tPvErr errCode;
    bool failed = false;
    unsigned long FrameSize = 0;
    
    //open camera
    if ((errCode = PvCameraOpen(GCamera.UID,ePvAccessMaster,&(GCamera.Handle))) != ePvErrSuccess)
    {
        if (errCode == ePvErrAccessDenied)
            printf("PvCameraOpen returned ePvErrAccessDenied:\nCamera already open as Master, or camera wasn't properly closed and still waiting to HeartbeatTimeout.");
        else
            printf("PvCameraOpen err: %u\n", errCode);
        return false;
    }
    
    // Calculate frame buffer size
    if((errCode = PvAttrUint32Get(GCamera.Handle,"TotalBytesPerFrame",&FrameSize)) != ePvErrSuccess)
    {
        printf("CameraSetup: Get TotalBytesPerFrame err: %u\n", errCode);
        return false;
    }
    
    // allocate the frame buffers
    for(int i=0;i<FRAMESCOUNT && !failed;i++)
    {
        GCamera.Frames[i].ImageBuffer = new char[FrameSize];
        if(GCamera.Frames[i].ImageBuffer)
        {
            GCamera.Frames[i].ImageBufferSize = FrameSize;
        }
        else
        {
            printf("CameraSetup: Failed to allocate buffers.\n");
            failed = true;
        }
    }
    
    return !failed;
}

-(void)closeCamera{
    tPvErr errCode;
	
    if((errCode = PvCameraClose(GCamera.Handle)) != ePvErrSuccess)
	{
		printf("CameraUnSetup: PvCameraClose err: %u\n", errCode);
	}
	else
	{
		printf("Camera closed.\n");

        // delete image buffers
        for(int i=0;i<FRAMESCOUNT;i++)
            delete [] (char*)GCamera.Frames[i].ImageBuffer;

	}
    
    GCamera.Handle = NULL;
}

-(BOOL)startStreamCamera{
    tPvErr errCode;
	bool failed = false;
    
    // NOTE: This call sets camera PacketSize to largest sized test packet, up to 8228, that doesn't fail
	// on network card. Some MS VISTA network card drivers become unresponsive if test packet fails. 
	// Use PvUint32Set(handle, "PacketSize", MaxAllowablePacketSize) instead. See network card properties
	// for max allowable PacketSize/MTU/JumboFrameSize. 
	if((errCode = PvCaptureAdjustPacketSize(GCamera.Handle,8228)) != ePvErrSuccess)
	{
		printf("CameraStart: PvCaptureAdjustPacketSize err: %u\n", errCode);
		return false;
	}
    
    // start driver capture stream 
	if((errCode = PvCaptureStart(GCamera.Handle)) != ePvErrSuccess)
	{
		printf("CameraStart: PvCaptureStart err: %u\n", errCode);
		return false;
	}
    
    // queue frames with FrameDoneCB callback function. Each frame can use a unique callback function
	// or, as in this case, the same callback function.
	for(int i=0;i<FRAMESCOUNT && !failed;i++)
	{           
		if((errCode = PvCaptureQueueFrame(GCamera.Handle,&(GCamera.Frames[i]),FrameDoneCB)) != ePvErrSuccess)
		{
			printf("CameraStart: PvCaptureQueueFrame err: %u\n", errCode);
			failed = true;
		}
	}
    
	if (failed)
		return false;
    
	// set the camera in freerun trigger, continuous mode, and start camera receiving triggers
	if((PvAttrEnumSet(GCamera.Handle,"FrameStartTriggerMode","Freerun") != ePvErrSuccess) ||
       (PvAttrEnumSet(GCamera.Handle,"AcquisitionMode","Continuous") != ePvErrSuccess) ||
       (PvCommandRun(GCamera.Handle,"AcquisitionStart") != ePvErrSuccess))
	{		
		printf("CameraStart: failed to set camera attributes\n");
		return false;
	}	
    
	return true;
}

-(void)stopStreamCamera{
    tPvErr errCode;
	
	//stop camera receiving triggers
	if ((errCode = PvCommandRun(GCamera.Handle,"AcquisitionStop")) != ePvErrSuccess)
		printf("AcquisitionStop command err: %u\n", errCode);
	else
		printf("\nAcquisitionStop success.\n");
    
	//PvCaptureQueueClear aborts any actively written frame with Frame.Status = ePvErrDataMissing
	//Further queued frames returned with Frame.Status = ePvErrCancelled
	
	//Add delay between AcquisitionStop and PvCaptureQueueClear
	//to give actively written frame time to complete
	sleep(200);
	
	printf("Calling PvCaptureQueueClear...\n");
	if ((errCode = PvCaptureQueueClear(GCamera.Handle)) != ePvErrSuccess)
		printf("PvCaptureQueueClear err: %u\n", errCode);
	else
		printf("...Queue cleared.\n");  
    
	//stop driver stream
	if ((errCode = PvCaptureEnd(GCamera.Handle)) != ePvErrSuccess)
		printf("PvCaptureEnd err: %u\n", errCode);
	else
		printf("Driver stream stopped.\n");
}


@end
