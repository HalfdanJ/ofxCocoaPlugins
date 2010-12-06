//
//  NormalCameraInstance.mm
//  loadnloop
//
//  Created by Jonas Jongejan on 21/05/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "NormalCameraInstance.h"


@implementation NormalCameraInstance
@synthesize guid;

+(NSMutableArray*) deviceList{
	NSMutableArray * ret = [NSMutableArray array];

	
	OSErr err = noErr;
	
	ComponentDescription	theDesc;
	Component				sgCompID;
	SGChannel 			gVideoChannel;
	SeqGrabComponent	gSeqGrabber;

	// this crashes when we get to
	// SGNewChannel
	// we get -9405 as error code for the channel
	// -----------------------------------------
	// gSeqGrabber = OpenDefaultComponent(SeqGrabComponentType, 0);
	
	// this seems to work instead (got it from hackTV)
	// -----------------------------------------
	theDesc.componentType = SeqGrabComponentType;
	theDesc.componentSubType = NULL;
	theDesc.componentManufacturer = 'appl';
	theDesc.componentFlags = NULL;
	theDesc.componentFlagsMask = NULL;
	sgCompID = FindNextComponent (NULL, &theDesc);
	// -----------------------------------------
	
	gSeqGrabber = OpenComponent(sgCompID);
	
	err = GetMoviesError();
	
	err = SGInitialize(gSeqGrabber);
	
	err = SGSetDataRef(gSeqGrabber, 0, 0, seqGrabDontMakeMovie);
	
	// windows crashes w/ out gworld, make a dummy for now...
	// this took a long time to figure out.
	err = SGSetGWorld(gSeqGrabber, 0, 0);
	
	err = SGNewChannel(gSeqGrabber, VideoMediaType, &(gVideoChannel));

	
	
	
	
	
	
	printf("-------------------------------------\n");
	
	/*
	 //input selection stuff (ie multiple webcams)
	 //from http://developer.apple.com/samplecode/SGDevices/listing13.html
	 //and originally http://lists.apple.com/archives/QuickTime-API/2008/Jan/msg00178.html
	 */
	
	SGDeviceList deviceList;
	SGGetChannelDeviceList (gVideoChannel, sgDeviceListIncludeInputs, &deviceList);
	unsigned char pascalName[256];
	unsigned char pascalNameInput[256];
	
	int deviceCount = 0;
	
	for(int i = 0 ; i < (*deviceList)->count ; ++i)
	{
		SGDeviceName nameRec;
		nameRec = (*deviceList)->entry[i];
		SGDeviceInputList deviceInputList = nameRec.inputs;
		
		int numInputs = 0;
		if( deviceInputList ) numInputs = ((*deviceInputList)->count);
		
		memcpy(pascalName, (*deviceList)->entry[i].name, sizeof(char) * 256);
		
		//this means we can use the capture method
		if(nameRec.flags != sgDeviceNameFlagDeviceUnavailable){
			
			//if we have a capture 'device' (qt's word not mine - I would prefer 'system' ) that is ready to be used
			//we go through its inputs to list all physical devices - as there could be more than one!
			for(int j = 0; j < numInputs; j++){
				
				
				//if our 'device' has inputs we get their names here
				if( deviceInputList ){
					SGDeviceInputName inputNameRec  = (*deviceInputList)->entry[j];
					memcpy(pascalNameInput, inputNameRec.name, sizeof(char) * 256);
				}
				
				printf( "device[%i] %s - %s\n",  deviceCount, p2cstr(pascalName), p2cstr(pascalNameInput) );
				
				[ret addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%i", deviceCount], @"guid", 
									[NSString stringWithFormat:@"%s", p2cstr(pascalNameInput) ], @"desc", 
									[NSString stringWithFormat:@"device %i: %s - %s", deviceCount, p2cstr(pascalName), p2cstr(pascalNameInput) ], @"name",
									[NSNumber numberWithInt:0], @"referenceCount",
									@"normal", @"type",
									
									nil]];
				
				
				//we count this way as we need to be able to distinguish multiple inputs as devices
				deviceCount++;
			}
			
		}else{
			printf( "(unavailable) device[%i] %s\n",  deviceCount, p2cstr(pascalName) );
			deviceCount++;
		}
	}
	printf( "-------------------------------------\n");
	
	SGStop (gSeqGrabber);
	CloseComponent (gSeqGrabber);
	
	
	return ret;
}


-(id)initWithGuid:(NSString*)_guid named:(NSString*)_name{
	if([self init]){
		[self setGuid:_guid];

		[self setStatus:@"Initializing"];

		grabber = new ofVideoGrabber();
		grabber->setDeviceID([[self guid] intValue]);
		
		if(grabber->initGrabber(800, 600, true)){
			[self setStatus:@"OK"];	
		} else {
			[self setStatus:@"ERROR"];	
		}
		tex = &grabber->getTextureReference();

		
		[self setName:_name];
	}
	return self;
}

-(NSView *) makeViewInRect:(NSRect)rect{
	NSView * view = [[NSView alloc]initWithFrame:rect];
	return view;
}

-(void) update{
	grabber->update();
	tex = &grabber->getTextureReference();

}

@end
