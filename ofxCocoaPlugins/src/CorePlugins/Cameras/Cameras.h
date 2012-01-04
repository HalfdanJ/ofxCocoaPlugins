#pragma once

#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/Camera.h>


#define GetCamera(i) [GetPlugin(Cameras) getCamera:i]

@interface Cameras : ofPlugin {
	int numberCameras;
	
	//The camera "links" that points to a cameraInstance
	NSArray * cameras;
	
	//All the instances
	NSMutableDictionary * cameraInstances;
	

}

@property (readonly) int numberCameras;
@property (readonly) NSArray * cameras;
@property (retain) NSMutableDictionary * cameraInstances;

-(id)initWithNumberCameras:(int)numCameras;
-(Camera*) getCamera:(int)n;

@end
