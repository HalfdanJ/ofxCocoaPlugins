#import "AVTCameraInstance.h"

@implementation AVTCameraInstance
@synthesize uid;
@synthesize modelName, ip, exposure, gain, sensorSize, roiWidth, roiHeight, roiLeft, roiTop;

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

-(void)update{
    [lock lock];
    tPvFrame * frame = &GCamera.Frames[processIndex];
    if([self camInited] && frame->Status == ePvErrSuccess && lastProcessedFramecount != frame->FrameCount && processIndex != circleIndex){
        lastProcessedFramecount = processIndex;
        
        //Process!
        //New size image
        if(width != frame->Width || height != frame->Height){

            width = frame->Width;
            height = frame->Height;
            
            cout<<"Camera size: "<<frame->Width <<" x "<<frame->Height<<endl;
            
            if(frame->Format == ePvFmtMono8){
                tex->allocate(width, height, GL_LUMINANCE);
                
                delete pixels;
                pixels = new unsigned char[width * height];
                memset(pixels, 0, width*height);
            }        
        }
        
        //Copy data
        
        memcpy(pixels,frame->ImageBuffer,frame->ImageBufferSize);
        if(frame->Format == ePvFmtMono8){
            tex->loadData((unsigned char*)pixels, width, height, GL_LUMINANCE);
        }
        frameNum ++;
        
        
    } 
    [lock unlock];

}

#pragma mark Thread
-(void) threadedFunction{
    while(![self camIsClosing] && [self camIsConnected]){
        if([self camIsIniting]){
            if(!GCamera.UID && !GCamera.Abort)
            {
                GCamera.UID = [self uid];    
                [self setStatus:@"Opening camera..."];
                if([self openCamera])
                {
                    printf("Camera %lu opened\n",[self uid]);   
                    
                    // start streaming from the camera
                    [self setStatus:@"Starting stream..."];
                    if([self startStreamCamera])
                    {
                        //create a thread to display camera stats. 
                        [self setCamInited:YES];
                        [self readCameraSettings];
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
            tPvFrame * frame = &GCamera.Frames[circleIndex];
           // cout<<"Wait for frame "<<circleIndex<<endl;
            PvCaptureWaitForFrameDone(GCamera.Handle, frame, 2000);
            //cout<<"Wait for frame "<<circleIndex<<" DONE "<<endl;            
            
            [lock lock];
            
           
            //requeue frame
//            if(frame->Status == ePvErrSuccess && !GCamera.Abort && ![self camIsClosing]){
            if(frame->Status == ePvErrSuccess){
                processIndex = circleIndex;
            } else {
                cout<<"Data loss"<<endl;
            }
            
            if(!GCamera.Abort && ![self camIsClosing]){
            //    cout<<"Capture Queue "<<circleIndex<<"  "<<endl;            
                PvCaptureQueueFrame(GCamera.Handle, frame, NULL);
            } else {
                cout<<"Abort "<<circleIndex<<"bor "<<endl;            
            }

            circleIndex++;
            if(circleIndex==FRAMESCOUNT)
                circleIndex = 0;    
            
           
            [lock unlock];

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
//    	if((errCode = PvCaptureAdjustPacketSize(GCamera.Handle,140)) != ePvErrSuccess)
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
    circleIndex = 0;
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
    
    //Set Bytes per second
    //Height x Width x FrameRate x Bytes per Pixel
    //
    if((PvAttrUint32Set(GCamera.Handle,"StreamBytesPerSecond",100*968*1200) != ePvErrSuccess))
	{		
		printf("CameraStart: failed to set camera Bytes per second\n");
		return false;
	}	

	// set the camera in freerun trigger, continuous mode, and start camera receiving triggers
	if((PvAttrEnumSet(GCamera.Handle,"FrameStartTriggerMode","Freerun") != ePvErrSuccess) ||
       (PvAttrEnumSet(GCamera.Handle,"AcquisitionMode","Continuous") != ePvErrSuccess) ||
       (PvCommandRun(GCamera.Handle,"AcquisitionStart") != ePvErrSuccess))
	{		
		printf("CameraStart: failed to set camera attributes\n");
		return false;
	}	
    
    char lValue[128];
    if(PvAttrStringGet(GCamera.Handle,"DeviceModelName",lValue,128,NULL) == ePvErrSuccess)
    {
        [self setModelName:[NSString stringWithCString:lValue encoding:NSUTF8StringEncoding]];
    }
  //  NSLog(@"Camera name %@",self.modelName);
    
    //Binning
    if((PvAttrUint32Set(GCamera.Handle,"BinningX",2) != ePvErrSuccess))
	{		
		printf("CameraStart: failed to set binning x\n");
		return false;
	}	
    if((PvAttrUint32Set(GCamera.Handle,"BinningY",2) != ePvErrSuccess))
	{		
		printf("CameraStart: failed to set binning y\n");
		return false;
	}	
    
    
   /* if([self.modelName isEqualToString:@"Manta_G-201B"]){
        if((PvAttrUint32Set(GCamera.Handle,"Width",642) != ePvErrSuccess))
        {		
            printf("CameraStart: failed to set ROI y\n");
            return false;
        }	
        
        if((PvAttrUint32Set(GCamera.Handle,"Height",481) != ePvErrSuccess))
        {		
            printf("CameraStart: failed to set ROI y\n");
            return false;
        }	
        
        if((PvAttrUint32Set(GCamera.Handle,"RegionX",100) != ePvErrSuccess))
        {		
            printf("CameraStart: failed to set ROI y\n");
            return false;
        }
    }
    */
    PvAttrEnumSet(GCamera.Handle, "ExposureMode", "Manual");
    PvAttrEnumSet(GCamera.Handle, "GainMode", "Manual");

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


#pragma mark View
-(NSView *) makeViewInRect:(NSRect)rect{
    int x1 = 17;
    int x2 = 103;
    
    int y = 376;
    
	NSView * view = [[NSView alloc]initWithFrame:rect];
	
	NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x1, y, 84, 17)];
	[textField setStringValue:@"Model:"];
	[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[textField setAlignment:NSRightTextAlignment];
	[view addSubview:textField];
    
    textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x2, y, 84, 17)];
	[textField setStringValue:@""];

	[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[textField setAlignment:NSLeftTextAlignment];
    [textField bind:@"value" toObject:self withKeyPath:@"modelName" options:nil];
	[view addSubview:textField];

    y -= 16;
    
    textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x1, y, 84, 17)];
	[textField setStringValue:@"IP:"];
	[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[textField setAlignment:NSRightTextAlignment];
	[view addSubview:textField];
    
    textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x2, y, 84, 17)];
	[textField setStringValue:@""];
    
	[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[textField setAlignment:NSLeftTextAlignment];
    [textField bind:@"value" toObject:self withKeyPath:@"ip" options:nil];
	[view addSubview:textField];
    
    y -= 16;
    
    textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x1, y, 84, 17)];
	[textField setStringValue:@"Sensor:"];
	[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[textField setAlignment:NSRightTextAlignment];
	[view addSubview:textField];
    
    textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x2, y, 84, 17)];
	[textField setStringValue:@""];
    
	[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[textField setAlignment:NSLeftTextAlignment];
    [textField bind:@"value" toObject:self withKeyPath:@"sensorSize" options:nil];
	[view addSubview:textField];


    y -= 20;
    
    for(int i=0;i<2;i++){
		NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, y, 84, 17)];
		[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
		[textField setAlignment:NSRightTextAlignment];
		[view addSubview:textField];
		
		NSSlider * slider = [[NSSlider alloc] initWithFrame:NSMakeRect(103, y-5, 180, 26)];
		[view addSubview:slider];
		
		switch (i) {
			case 0:
				[textField setStringValue:@"Exposure:"];
				[slider setMinValue:0];
				[slider setMaxValue:30000];
				[slider bind:@"value" toObject:self withKeyPath:@"exposure" options:nil];
				break;
			case 1:
				[textField setStringValue:@"Gain:"];
				[slider setMinValue:0];
				[slider setMaxValue:20];
				[slider bind:@"value" toObject:self withKeyPath:@"gain" options:nil];
				
				break;

			default:
				break;
		}
        
        y -= 25;
	}
	
    
    y -= 20;
    
    for(int i=0;i<4;i++){
		NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, y, 84, 17)];
		[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
		[textField setAlignment:NSRightTextAlignment];
		[view addSubview:textField];
		
        NSTextField * textFieldVal = [[NSTextField alloc] initWithFrame:NSMakeRect(103, y-0, 60, 20)];
		[view addSubview:textFieldVal];
		
		switch (i) {
			case 0:
				[textField setStringValue:@"ROI Width:"];
				[textFieldVal bind:@"value" toObject:self withKeyPath:@"roiWidth" options:nil];
				break;
			case 1:
				[textField setStringValue:@"ROI Height:"];
				[textFieldVal bind:@"value" toObject:self withKeyPath:@"roiHeight" options:nil];
				
				break;
            case 2:
				[textField setStringValue:@"ROI Left:"];
				[textFieldVal bind:@"value" toObject:self withKeyPath:@"roiLeft" options:nil];
				
				break;
            case 3:
				[textField setStringValue:@"ROI Top:"];
				[textFieldVal bind:@"value" toObject:self withKeyPath:@"roiTop" options:nil];
				
				break;

			default:
				break;
		}
        
        y -= 25;
	}

    
    
    return view;
}

#pragma mark Camera settings



-(void) readCameraSettings{
    char lValue[128];
    if(PvAttrStringGet(GCamera.Handle,"DeviceModelName",lValue,128,NULL) == ePvErrSuccess)
    {
        [self setModelName:[NSString stringWithCString:lValue encoding:NSUTF8StringEncoding]];
    }
    
    if(PvAttrStringGet(GCamera.Handle,"DeviceIPAddress",lValue,128,NULL) == ePvErrSuccess)
    {
        [self setIp:[NSString stringWithCString:lValue encoding:NSUTF8StringEncoding]];
    }
    
    tPvUint32 uintValue;    
    if(PvAttrUint32Get(GCamera.Handle,"ExposureValue",&uintValue) == ePvErrSuccess){
        self.exposure = uintValue;
    }

    if(PvAttrUint32Get(GCamera.Handle,"GainValue",&uintValue) == ePvErrSuccess){
        self.gain = uintValue;
    }
    if(PvAttrUint32Get(GCamera.Handle,"RegionY",&uintValue) == ePvErrSuccess){
        self.roiTop = uintValue;
    }
    if(PvAttrUint32Get(GCamera.Handle,"RegionX",&uintValue) == ePvErrSuccess){
        self.roiLeft = uintValue;
    }
    if(PvAttrUint32Get(GCamera.Handle,"Width",&uintValue) == ePvErrSuccess){
        self.roiWidth = uintValue;
    }
    if(PvAttrUint32Get(GCamera.Handle,"Height",&uintValue) == ePvErrSuccess){
        self.roiHeight = uintValue;
    }

    
    tPvUint32 uintheight; 
    if(PvAttrUint32Get(GCamera.Handle,"SensorHeight",&uintheight) == ePvErrSuccess){
    }
    tPvUint32 uintwidth; 
    if(PvAttrUint32Get(GCamera.Handle,"SensorWidth",&uintwidth) == ePvErrSuccess){
    }
    
    self.sensorSize = [NSString stringWithFormat:@"%i x %i",uintwidth,uintheight];
}

-(void)setGain:(int)_gain{
    gain = _gain;
    PvAttrUint32Set(GCamera.Handle, "GainValue", gain);
}

-(void)setExposure:(int)_exp{
    exposure = _exp;
    PvAttrUint32Set(GCamera.Handle, "ExposureValue", exposure);
}

-(void)setRoiTop:(int)_roiTop{
    roiTop = _roiTop;
    PvAttrUint32Set(GCamera.Handle, "RegionY", roiTop);
}
-(void)setRoiLeft:(int)_roiLeft{
    roiLeft = _roiLeft;
    PvAttrUint32Set(GCamera.Handle, "RegionX", roiLeft);
}
-(void)setRoiWidth:(int)_roiWidth{
    roiWidth = _roiWidth;
    PvAttrUint32Set(GCamera.Handle, "Width", roiWidth);
}
-(void)setRoiHeight:(int)_roiHeight{
    roiHeight = _roiHeight;
    PvAttrUint32Set(GCamera.Handle, "Height", roiHeight);
}

@end
