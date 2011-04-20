#pragma once


#include "Plugin.h"
#include "Camera.h"
#include "Libdc1394Grabber.h"

#define GetCamera(i) [GetPlugin(Cameras) getCamera:i]

@interface Cameras : ofPlugin {
	int numberCameras;
	
	//The camera "links" that points to a cameraInstance
	NSArray * cameras;
	
	//All the instances
	NSMutableDictionary * cameraInstances;
	
	//Just to list the iidc cameras in the first place
	Libdc1394Grabber * iidcCamera;
}

@property (readonly) int numberCameras;
@property (readonly) NSArray * cameras;
@property (retain) NSMutableDictionary * cameraInstances;

-(id)initWithNumberCameras:(int)numCameras;
-(Camera*) getCamera:(int)n;

@end
