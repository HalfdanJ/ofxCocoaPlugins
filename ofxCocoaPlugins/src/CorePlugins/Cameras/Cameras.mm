

#import "Cameras.h"
#include "NormalCameraInstance.h"
#include "IIDCCameraInstance.h"
#include "AVTCamerasController.h"

@implementation Cameras
@synthesize numberCameras, cameras, cameraInstances;


-(id)initWithNumberCameras:(int)numCameras{
	if([self init]){
		numberCameras = numCameras;
		
		//Dictionary over types of cameras including instances 
		cameraInstances = [[NSMutableDictionary dictionary] retain];
		
		/*
        //Normal cameras
		[cameraInstances setObject:[NormalCameraInstance deviceList] forKey:@"Normal Cameras"];
		*/
        
        //AVT cameras
        NSDictionary * avt = [NSDictionary dictionaryWithObjectsAndKeys:[[AVTCamerasController alloc] init], @"controller", nil];
		[cameraInstances setObject:avt forKey:@"AVT Cameras"];

		
        /*
		//Create an array of dc1394 cameras (for example point grey cameras)
		NSArray * iidc = [NSArray array]; 
		NSMutableArray * iidcTmp = [NSMutableArray array]; 
		
        
        //Just to list the iidc cameras in the first place
        Libdc1394Grabber * iidcCamera;
		iidcCamera = new Libdc1394Grabber();
		iidcCamera->enumerateDevices();
		for (uint32_t index = 0; index < iidcCamera->cameraList->num; index++) {
			//Create the instance
			[iidcTmp addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
							 [NSString stringWithFormat:@"%llx", iidcCamera->cameraList->ids[index].guid], @"guid", 
							 [NSString stringWithFormat:@"Camera %llx", iidcCamera->cameraList->ids[index].guid], @"name",
							 [NSNumber numberWithInt:0], @"referenceCount",
							 @"iidc", @"type",
							 
							 nil]];
		}		
		
		//Sort the dc1394 cameras by guid, so the list is the same every time the program starts
		NSSortDescriptor *firstDescriptor =
		[[[NSSortDescriptor alloc] initWithKey:@"guid"
									 ascending:YES
									  selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
		
		NSArray *descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
		iidc = [iidcTmp sortedArrayUsingDescriptors:descriptors];

		//Set the iidc or dc1394 cameras
		[cameraInstances setObject:iidc forKey:@"IIDC Cameras"];
         */
		
		
		//Create the camera holders
		NSMutableArray * _cameras = [NSMutableArray arrayWithCapacity:numCameras];
		for(int i=0;i<numCameras;i++){
			Camera * newCam = [[Camera alloc] initWithCameraInstances:cameraInstances];
			[_cameras addObject:newCam];
		}
		cameras = [[NSArray arrayWithArray:_cameras] retain];
		

    
	//	[self addObserver:self forKeyPath:@"customProperties" options:nil context:@"customProperties"];		
		
	}
	return self;
}

-(BOOL)autoresizeControlview{
    return YES;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	/*if([(NSString*)context isEqualToString:@"customProperties"]){			
		Camera * cam;
		NSLog(@"%@ %lu",customProperties,[[customProperties objectForKey:@"cameras"] count]);
		int i=0;
		for(cam in cameras){
			if([[customProperties objectForKey:@"cameras"] count] > i){
				NSMutableDictionary * dict = [[customProperties objectForKey:@"cameras"] objectAtIndex:i];
				if([[[cam cameraTypesController] arrangedObjects] count] >= [[dict objectForKey:@"SelectionIndexType"]intValue] && [[[cam cameraInstancesController]arrangedObjects]  count] >= [[dict objectForKey:@"SelectionIndexCamera"]intValue]){ 
					[[cam cameraTypesController] setSelectionIndex:[[dict objectForKey:@"SelectionIndexType"]intValue]];
					[[cam cameraInstancesController] setSelectionIndex:[[dict objectForKey:@"SelectionIndexCamera"]intValue]];	
					
					[[[cam cameraInstance] objectForKey:@"object"] loadSettingsDict:dict];
				}
			}
			i++;			
		}		
	}*/
}
/*
-(NSMutableDictionary *) customProperties{
	//Read the settings of the selected cameras
	
	NSMutableDictionary * dict = customProperties;
	NSMutableArray * camerasArray = [NSMutableArray arrayWithCapacity:[cameras count]];
	
	Camera * cam;
	for(cam in cameras){
		if([cam cameraInstance] != nil){
			NSMutableDictionary * props = [NSMutableDictionary dictionary];
			[props setObject:[[[cam cameraInstance] objectForKey:@"object"]guid] forKey:@"guid"];
			
			[props setObject:[NSNumber numberWithInt:[[cam cameraTypesController] selectionIndex]] forKey:@"SelectionIndexType"];
			[props setObject:[NSNumber numberWithInt:[[cam cameraInstancesController] selectionIndex]] forKey:@"SelectionIndexCamera"];
			
			[[[cam cameraInstance] objectForKey:@"object"] addPropertiesToSave:props];
			
			[camerasArray addObject:props];
		}
		
		
	}
	
	[dict setObject:camerasArray forKey:@"cameras"];
	return dict;
}
*/

-(void) awakeFromNib{
	[super awakeFromNib];
	
	int height = 700;
	int width = 300;
	[[self view] setFrameSize:NSMakeSize(numberCameras * width, height)];
	
	
	//Lines 
	for(int i=0;i<numberCameras-1;i++){
		NSBox * verticalLine = [[NSBox alloc] initWithFrame:NSMakeRect(width*(i+1)-1, 0, 1, height - 248)];
		[verticalLine setBoxType:NSBoxCustom];
		[[self view] addSubview:verticalLine];
	}
	
	NSBox * verticalLine = [[NSBox alloc] initWithFrame:NSMakeRect(numberCameras * width-1, 0, 1, height)];
	[verticalLine setBoxType:NSBoxCustom];
	[[self view] addSubview:verticalLine];
	NSBox * horzLine = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, numberCameras*width,1)];
	[horzLine setBoxType:NSBoxCustom];
	[[self view] addSubview:horzLine];
	
	Camera * cam;
	int i=0;
	for(cam in cameras){
        NSView * view = [cam makeViewInRect:NSMakeRect(width*i, 0, width, height - 223) ];
        [view setAutoresizingMask:NSViewMinYMargin];		
        [[self view] addSubview:view];
		i++;
	}
    
    //Resize opengl view and gray bar
    [[[[self view] subviews] objectAtIndex:0] setFrameSize:NSMakeSize(width*i, height)];
    [[[[self view] subviews] objectAtIndex:1] setFrameSize:NSMakeSize(width*i, height)];
	
	
	
}

-(BOOL)willDraw:(NSMutableDictionary *)drawingInformation{
	return NO;
}

-(void) update:(NSDictionary *)drawingInformation{
	Camera * cam;
	int i=0;
	for(cam in cameras){
		[cam update];
		i++;
	}
	
	//Call update on the instance, if its referenceCount is greater then 0 (= there is a camera link attached to it)
/*	NSArray * values = [cameraInstances allValues];	
	NSArray * _cameras;
	for(_cameras in values){
		NSMutableDictionary * camDict;
		for(camDict in _cameras){
			if([[camDict objectForKey:@"referenceCount"] intValue] > 0){
				[[camDict objectForKey:@"object"] update];
			}
		}
	}
	*/
	
}

-(void) setup{
	Camera * cam;
	int i=0;
	for(cam in cameras){
		[cam setup];
		i++;
	}
}

-(void) controlDraw:(NSDictionary *)drawingInformation{
	ofBackground(0, 0, 0);
	Camera * cam;
	int i=0;
	for(cam in cameras){
		[cam draw:NSMakeRect(300*i, 0, 300, 225)];
		i++;
	}
}

-(Camera*) getCamera:(int)n{
	return [cameras objectAtIndex:n];
}

-(void)applicationWillTerminate:(NSNotification *)note{
    NSLog(@"Close cameras");

	for(NSDictionary * controller in [cameraInstances allValues]){
        [[controller objectForKey:@"controller"] closeCameras];
	}
    
}
@end
