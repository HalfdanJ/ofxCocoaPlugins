//
//  CameraInstance.mm
//  loadnloop
//
//  Created by LoadNLoop on 27/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraInstance.h"


@implementation CameraInstance

@synthesize name, status, tex, pixels, enabled, cameraInstances;

-(id) init{
	if([super init]){
		camInited = NO;
		camIsIniting = NO;
		camWasInited = NO;
		isClosing = NO;
		
		
		width = 640;
		height = 480;
		myframes = 0;
		
		tex = new ofTexture();
		pixels = new unsigned char[width * height*3];
		memset(pixels, 0, width*height*3);
		
	}
	return self;
}

-(void) drawCamera:(NSRect)rect{
	tex->draw(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}
-(void) loadSettingsDict:(NSMutableDictionary*)dict{}
-(void) addPropertiesToSave:(NSMutableDictionary*)dict{}
@end
