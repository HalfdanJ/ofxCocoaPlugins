#import "IIDCCameraInstance.h"

#include "Libdc1394Grabber.h"
#include "Libdc1394GrabberUtils.h"
#include "Libdc1394GrabberFramerateHelper.h"
#include "Libdc1394GrabberVideoFormatHelper.h"

@implementation IIDCCameraInstance
@synthesize gamma,whitebalance1,whitebalance2,brightness, shutter,gain, guid, videoGrabber, videoModes, videoMode, videoColorCoding, videoColorCodings, videoFramerates, videoFramerate;

-(id)initWithGuid:(NSString*)_guid{
	if(self = [self init]){
		[self setName:@"PTGrey"];
		[self setStatus:@"Initializing"];
		
		guid = [_guid retain];
		hasBlacked = NO;
		camIsIniting = YES;
		
		disabled  = NO;
		lock = [[NSRecursiveLock alloc] init];
		
		videoModes = [[NSMutableDictionary dictionary]retain];
		videoModesController = [[[NSDictionaryController alloc]init] retain];
		[videoModesController bind:@"contentDictionary" toObject:self withKeyPath:@"videoModes" options:nil];
		[videoModesController addObserver:self forKeyPath:@"selection" options:nil context:@"videoMode"];
		
		videoColorCodings = [[NSMutableDictionary dictionary]retain];
		videoColorCodingsController = [[[NSDictionaryController alloc]init] retain];
		[videoColorCodingsController bind:@"contentDictionary" toObject:self withKeyPath:@"videoColorCodings" options:nil];
		[videoColorCodingsController addObserver:self forKeyPath:@"selection" options:nil context:@"videoColorCoding"];
		
		
		videoFramerates = [[NSMutableDictionary dictionary]retain];
		videoFrameratesController = [[[NSDictionaryController alloc]init] retain];
		[videoFrameratesController bind:@"contentDictionary" toObject:self withKeyPath:@"videoFramerates" options:nil];
		[videoFrameratesController addObserver:self forKeyPath:@"selection" options:nil context:@"videoFramerate"];
		
		[self setEnabled:YES];
		videoMode = DC1394_VIDEO_MODE_640x480_MONO8;
		videoFramerate = Libdc1394GrabberFramerateHelper::numToDcLibFramerate( 30);
		videoColorCoding =  (dc1394color_coding_t) 0;
		
		[self setGamma:[NSNumber numberWithInt:0]];
				[self setGain:[NSNumber numberWithInt:0]];
				[self setShutter:[NSNumber numberWithInt:0]];
				[self setWhitebalance1:[NSNumber numberWithInt:0]];
				[self setWhitebalance2:[NSNumber numberWithInt:0]];
				[self setBrightness:[NSNumber numberWithInt:0]];
	}
	return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*) context isEqualToString:@"videoMode"]){
		//Video mode has changed
		if([[videoModesController selectedObjects]lastObject] != nil){
			[self setVideoMode:(dc1394video_mode_t)[[(id)[[[videoModesController selectedObjects]lastObject] value] objectForKey:@"mode"] intValue]];
		}
	}
	if([(NSString*) context isEqualToString:@"videoFramerate"]){
		//Video framerate has changed
		if([[videoFrameratesController selectedObjects]lastObject] != nil){
			[self setVideoFramerate:(dc1394framerate_t)[[(id)[[[videoFrameratesController selectedObjects]lastObject] value] objectForKey:@"mode"] intValue]];
		}
	}
	if([(NSString*) context isEqualToString:@"videoColorCoding"]){
		//Video color has changed
		if([[videoColorCodingsController selectedObjects]lastObject] != nil){
			[self setVideoColorCoding:(dc1394color_coding_t)[[(id)[[[videoModesController selectedObjects]lastObject] value] objectForKey:@"mode"] intValue]];
		}
	}
}


-(NSView *) makeViewInRect:(NSRect)rect{
	NSView * view = [[NSView alloc]initWithFrame:rect];
	
	NSTextField * modeTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 376, 84, 17)];
	[modeTextField setStringValue:@"Mode:"];
	[modeTextField setEditable:NO];	[modeTextField setBordered:NO];	[modeTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[modeTextField setAlignment:NSRightTextAlignment];
	[view addSubview:modeTextField];
	
	NSPopUpButton * modeDropdown = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(103, 369, 180, 26)];
	[modeDropdown bind:@"contentValues" toObject:videoModesController withKeyPath:@"arrangedObjects.key" options:nil];
	[modeDropdown bind:@"selectedIndex" toObject:videoModesController withKeyPath:@"selectionIndex" options:nil];
	[view addSubview:modeDropdown];
	
	NSTextField * colorTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 351, 84, 17)];
	[colorTextField setStringValue:@"Color mode:"];
	[colorTextField setEditable:NO];	[colorTextField setBordered:NO];	[colorTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[colorTextField setAlignment:NSRightTextAlignment];
	[view addSubview:colorTextField];
	
	NSPopUpButton * colorDropdown = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(103, 344, 180, 26)];
	[colorDropdown bind:@"contentValues" toObject:videoColorCodingsController withKeyPath:@"arrangedObjects.key" options:nil];
	[colorDropdown bind:@"selectedIndex" toObject:videoColorCodingsController withKeyPath:@"selectionIndex" options:nil];
	[view addSubview:colorDropdown];
	
	NSTextField * framerateTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 326, 84, 17)];
	[framerateTextField setStringValue:@"Framerate:"];
	[framerateTextField setEditable:NO];	[framerateTextField setBordered:NO];	[framerateTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[framerateTextField setAlignment:NSRightTextAlignment];
	[view addSubview:framerateTextField];
	
	NSPopUpButton *framerateDropdown = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(103, 319, 180, 26)];
	[framerateDropdown bind:@"contentValues" toObject:videoFrameratesController withKeyPath:@"arrangedObjects.key" options:nil];
	[framerateDropdown bind:@"selectedIndex" toObject:videoFrameratesController withKeyPath:@"selectionIndex" options:nil];
	[view addSubview:framerateDropdown];
	
	NSButton *applyAllButton = [[NSButton alloc] initWithFrame:NSMakeRect(103, 20, 180, 26)];
	[applyAllButton setBezelStyle:NSTexturedRoundedBezelStyle];
	[applyAllButton setTitle:@"Apply to all cameras"];
	[applyAllButton setTarget:self];
	[applyAllButton setAction:@selector(applyToAll)];
//	[framerateDropdown bind:@"contentValues" toObject:videoFrameratesController withKeyPath:@"arrangedObjects.key" options:nil];
//	[framerateDropdown bind:@"selectedIndex" toObject:videoFrameratesController withKeyPath:@"selectionIndex" options:nil];
	[view addSubview:applyAllButton];
	
	
	
	for(int i=0;i<6;i++){
		NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 301-25*i, 84, 17)];
		[textField setEditable:NO];	[textField setBordered:NO];	[textField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
		[textField setAlignment:NSRightTextAlignment];
		[view addSubview:textField];
		
		NSSlider * slider = [[NSSlider alloc] initWithFrame:NSMakeRect(103, 319-25-25*i, 180, 26)];
		[view addSubview:slider];
		
		switch (i) {
			case 0:
				[textField setStringValue:@"Gamma:"];
				[slider setMinValue:1];
				[slider setMaxValue:2];
				[slider bind:@"value" toObject:self withKeyPath:@"gamma" options:nil];
				break;
			case 1:
				[textField setStringValue:@"White balance 1:"];
				[slider setMinValue:0];
				[slider setMaxValue:1023];
				[slider bind:@"value" toObject:self withKeyPath:@"whitebalance1" options:nil];
				
				break;
				
			case 2:
				[textField setStringValue:@"White balance 2:"];
				[slider setMinValue:0];
				[slider setMaxValue:1023];
				[slider bind:@"value" toObject:self withKeyPath:@"whitebalance2" options:nil];
				
				break;
				
			case 3:
				[textField setStringValue:@"Brightness:"];
				[slider setMinValue:0];
				[slider setMaxValue:255];
				[slider bind:@"value" toObject:self withKeyPath:@"brightness" options:nil];
				
				break;
			case 4:
				[textField setStringValue:@"Gain:"];
				[slider setMinValue:0];
				[slider setMaxValue:255];
				[slider bind:@"value" toObject:self withKeyPath:@"gain" options:nil];
				
				break;
				
			case 5:
				[textField setStringValue:@"Shutter:"];
				[slider setMinValue:0];
				[slider setMaxValue:1280];
				[slider bind:@"value" toObject:self withKeyPath:@"shutter" options:nil];
				
				break;
			default:
				break;
		}
	}
	
	
	return view;
	
}

-(void) loadSettingsDict:(NSMutableDictionary*)dict{
	if([dict objectForKey:@"gamma"] != nil){
		[self setGamma:[dict objectForKey:@"gamma"]];
		[self setGain:[dict objectForKey:@"gain"]];
		[self setBrightness:[dict objectForKey:@"brightness"]];
		[self setShutter:[dict objectForKey:@"shutter"]];
		[self setWhitebalance1:[dict objectForKey:@"whitebalance1"]];
		[self setWhitebalance2:[dict objectForKey:@"whitebalance2"]];
	}
}

-(void) addPropertiesToSave:(NSMutableDictionary*)dict{
	[dict setObject:[self gamma] forKey:@"gamma"];
	[dict setObject:[self gain] forKey:@"gain"];
	[dict setObject:[self brightness] forKey:@"brightness"];
	[dict setObject:[self shutter] forKey:@"shutter"];
	[dict setObject:[self whitebalance1] forKey:@"whitebalance1"];
	[dict setObject:[self whitebalance2] forKey:@"whitebalance2"];
}

-(void) setGamma:(NSNumber *)n{
	[self willChangeValueForKey:@"gamma"];
	if(gamma != nil)
		[gamma release];
	
	gamma = [n retain];
	
	if(camInited){
		NSLog(@"Set gamma %f",[n floatValue]);
		videoGrabber->setFeatureValue([n floatValue], FEATURE_GAMMA );
	}
	
	[self didChangeValueForKey:@"gamma"];	
}	

-(void) setShutter:(NSNumber *)n{
	[self willChangeValueForKey:@"shutter"];
	if(shutter != nil)
		[shutter release];
	
	shutter = [n retain];
	
	if(camInited){
		NSLog(@"Set shutter %f",[n floatValue]);
		videoGrabber->setFeatureValue([n floatValue], FEATURE_SHUTTER );
	}
	
	[self didChangeValueForKey:@"shutter"];	
}	
-(void) setGain:(NSNumber *)n{
	[self willChangeValueForKey:@"gain"];
	if(gain != nil)
		[gain release];
	
	gain = [n retain];
	
	if(camInited){
		NSLog(@"Set gain %f",[n floatValue]);
		videoGrabber->setFeatureValue([n floatValue], FEATURE_GAIN );
	}
	
	[self didChangeValueForKey:@"gain"];	
}	

-(void) setBrightness:(NSNumber *)n{
	[self willChangeValueForKey:@"brightness"];
	if(brightness != nil)
		[brightness release];
	
	brightness = [n retain];
	
	if(camInited){
		NSLog(@"Set brightness %f",[n floatValue]);
		videoGrabber->setFeatureValue([n floatValue], FEATURE_BRIGHTNESS );
	}
	
	[self didChangeValueForKey:@"brightness"];	
}	


-(void) setWhitebalance1:(NSNumber *)n{
	[self willChangeValueForKey:@"whitebalance1"];
	if(whitebalance1 != nil)
		[whitebalance1 release];
	
	whitebalance1 = [n retain];
	
	if(camInited){
		NSLog(@"Set whitebalance 1 %f",[n floatValue]);
		videoGrabber->setFeatureValue([n floatValue], [whitebalance2 floatValue], FEATURE_WHITE_BALANCE );
	}
	
	[self didChangeValueForKey:@"whitebalance1"];	
}	

-(void) setWhitebalance2:(NSNumber *)n{
	[self willChangeValueForKey:@"whitebalance2"];
	if(whitebalance2 != nil)
		[whitebalance2 release];
	
	whitebalance2 = [n retain];
	
	if(camInited){
		NSLog(@"Set whitebalance 2 %f",[n floatValue]);
		videoGrabber->setFeatureValue([whitebalance1 floatValue], [n floatValue], FEATURE_WHITE_BALANCE );
	}
	
	[self didChangeValueForKey:@"whitebalance2"];	
}	



-(BOOL) isFrameNew{
	return bIsFrameNew;	
}


-(void) update{
	if(camIsIniting){
		[self videoGrabberInit];
	} 
	if(disabled && !hasBlacked){
		hasBlacked  = YES;
		unsigned char * bytes;
		bytes = new unsigned char[width*height*3];
            //int s = width*height*3;
		/*			for(int i=0;i<s;i++){
		 bytes[i] = 0;	
		 }*/
		memset(bytes,0,sizeof(bytes));
		tex->loadData(bytes, width, height, GL_RGB);
		
		//tex->clear();
	}
	
	if(camInited && [self enabled]){
		disabled = NO;
		//	[lock lock];
		bIsFrameNew = videoGrabber->grabFrame(&pixels);
	//	bIsFrameNew = NO;
		
		
		if(bIsFrameNew) {
			hasBlacked = NO;

			tex->loadData(pixels, width, height, GL_RGB);
			
			mytimeNow = ofGetElapsedTimef();
			if( (mytimeNow-mytimeThen) > 0.05f || myframes == 0 ) {
				myfps = myframes / (mytimeNow-mytimeThen);
				mytimeThen = mytimeNow;
				myframes = 0;
				frameRate = 0.5f * frameRate + 0.5f * myfps;
			}
			myframes++;
		}
		//[lock unlock];
		
	}else {
		disabled = YES;	
	}
	
	
}

-(void) setVideoMode:(dc1394video_mode_t)m{
	videoMode = m;
	
	if(camInited){
		//Respawn
		camIsIniting = YES;
		
	}
}

-(void) setVideoColorCoding:(dc1394color_coding_t)m{
	videoColorCoding = m;
	
	if(camInited){
		//Respawn
		camIsIniting = YES;
		
	}
}

-(void) setVideoFramerate:(dc1394framerate_t)m{
	videoFramerate = m;
	
	if(camInited){
		//Respawn
		camIsIniting = YES;
		
	}
}

-(void) close{
	if(videoGrabber != nil){
		videoGrabber->close();
		delete videoGrabber;
	}
	
	camInited = NO;
}

-(void) videoGrabberInit{
	
	camIsIniting = YES;
	camIsClosing = NO;
	
	if(camInited){
		NSLog(@"Restart camera");
		[self close];
	}
	
	videoGrabber = new Libdc1394Grabber();
	
	
	ofSetLogLevel(OF_LOG_VERBOSE);
	//videoGrabber->setFormat7(VID_FORMAT7_1);
	//	videoGrabber->listDevices();
	videoGrabber->setDiscardFrames(true);
	videoGrabber->set1394bMode(false);
	
	
	videoGrabber->setDeviceID([guid cStringUsingEncoding:NSUTF8StringEncoding]);	
	
	
	
	
	//Init the camera
	Libdc1394Grabber::libUseCount++;
    
	/*	if(videoGrabber->bUseFormat7){
	 dc1394color_coding_t desiredColorCoding = Libdc1394GrabberVideoFormatHelper::colorCodingFormat7FromParams(_format);
	 result = initCamera( _width,_height, DC1394_VIDEO_MODE_FORMAT7_0, (dc1394framerate_t) _frameRate, desiredColorCoding);
	 }else{*/
	//        dc1394video_mode_t desiredVideoMode	= Libdc1394GrabberVideoFormatHelper::videoFormatFromParams( _width, _height, _format );
	
	
	videoGrabber->width = width;
	videoGrabber->height = height;
	videoGrabber->targetFormat = VID_FORMAT_RGB;
	camInited = videoGrabber->initCamera( width,height, videoMode, videoFramerate, videoColorCoding);
	
	//	camInited = videoGrabber->init(width, height, VID_FORMAT_Y8, VID_FORMAT_GREYSCALE, 50, true);
	
	//camInited = videoGrabber->initCamera( width,height, DC1394_VIDEO_MODE_FORMAT7_0,  (dc1394framerate_t)25, DC1394_COLOR_CODING_MONO8);
	
	width = videoGrabber->outputImageWidth;
	height = videoGrabber->outputImageHeight;										  
	
	videoGrabber->initInternalBuffers();
	
	
	videoGrabber->startThread(true, false); //blocking, verbose
	
	
	
	
	
	// camInited = videoGrabber->init(640, 480, VID_FORMAT_GREYSCALE, VID_FORMAT_GREYSCALE, 30, true);
	tex->allocate(width,height,GL_RGB);
	
	/*if(camInited)
		camWasInited = camInited;
	*/
	if(camInited){		
		[self setStatus:@"OK"];
		
		//Update modes
		[self willChangeValueForKey:@"videoModes"];
		for(unsigned int i = 0; i < videoGrabber->video_modes.num; i++ )
		{
			dc1394video_mode_t mode = videoGrabber->video_modes.modes[i];
			const char * modeString = Libdc1394GrabberUtils::print_format(mode);
			
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			[dict setObject:[NSNumber numberWithInt:mode] forKey:@"mode"];
			
			[videoModes setObject:dict forKey:[NSString stringWithCString:modeString encoding:NSUTF8StringEncoding]];
		}
		[self didChangeValueForKey:@"videoModes"];
		
		[self willChangeValueForKey:@"videoFramerates"];
		for(unsigned int i = 0; i < videoGrabber->video_modes.num; i++ )
		{
			dc1394framerate_t mode = videoGrabber->framerates.framerates[i];
			const char * modeString = Libdc1394GrabberFramerateHelper::DcLibFramerateToString(mode);
			
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			[dict setObject:[NSNumber numberWithInt:mode] forKey:@"mode"];
			
			[videoFramerates setObject:dict forKey:[NSString stringWithCString:modeString  encoding:NSUTF8StringEncoding]];
		}
		[self didChangeValueForKey:@"videoFramerates"];
		
		videoGrabber->bVerbose = YES;
		videoGrabber->initFeatures();
		
		//Set all on manual
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_SHUTTER);
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_EXPOSURE);		
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_GAIN);		
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_GAMMA);				
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_BRIGHTNESS);	
		
		
		videoGrabber->setFeatureValue([shutter floatValue], FEATURE_SHUTTER );
		videoGrabber->setFeatureValue([gamma floatValue], FEATURE_GAMMA );
		videoGrabber->setFeatureValue([gain floatValue], FEATURE_GAIN ); 
		videoGrabber->setFeatureValue([brightness floatValue], FEATURE_BRIGHTNESS );
		videoGrabber->setFeatureValue([whitebalance1 floatValue], [whitebalance2 floatValue], FEATURE_WHITE_BALANCE );

	}
	camIsIniting = NO;
	
}

-(void) applyToAll{
	NSLog(@"Apply on all");
	NSDictionary * dict;
//	NSLog(@")
	for(dict in [cameraInstances objectForKey:@"IIDC Cameras"]){
		IIDCCameraInstance * cam = [dict objectForKey:@"object"];		
		if(cam != self){
			[cam setBrightness:[self brightness]];
			[cam setGain:[self gain]];
			[cam setGamma:[self gamma]];
			[cam setWhitebalance1:[self whitebalance1]];
			[cam setWhitebalance2:[self whitebalance2]];
			[cam setShutter:[self shutter]];
		}
	}
}

-(void)videoGrabberRespawn{}
@end
