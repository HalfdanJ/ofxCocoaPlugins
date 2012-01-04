//
//  CameraInstance.mm
//  loadnloop
//
//  Created by LoadNLoop on 27/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraInstance.h"


@implementation CameraInstance

@synthesize name, status, tex, pixels, enabled, cameraInstances, camIsConnected, camIsClosing, camInited, camIsIniting, referenceCount;

-(id) init{
	if([super init]){
		[self setCamInited:NO];
        [self setCamIsIniting:NO];
        [self setCamIsClosing:NO];
        [self setCamIsConnected:NO];

        referenceCount = 0;
		
		width = 640;
		height = 480;
		myframes = 0;
		
		tex = new ofTexture();
		pixels = new unsigned char[width * height*3];
		memset(pixels, 0, width*height*3);
        
		
	}
	return self;
}

-(void)setCamIsConnected:(BOOL)_camIsConnected{
    if(!_camIsConnected || camIsConnected != _camIsConnected){
        if(!_camIsConnected){
            [self setStatus:@"Not connected"];
        } else {
            [self setStatus:@"Inactive"];
        }
    }
    camIsConnected = _camIsConnected;
    
    if(!camIsConnected){
        [self setCamInited:NO];
        [self setCamIsIniting:NO];
        [self setCamIsClosing:NO];
    } else {
        if([self referenceCount] > 0 && ![self camInited] && ![self camIsIniting]){
            [self initCam];
        }
    }
}

-(void)setCamIsIniting:(BOOL)_camIsIniting{
    camIsIniting = _camIsIniting;
    if(camIsIniting){
        [self setStatus:@"Connecting..."];
    }
}

-(void)setCamInited:(BOOL)_camInited{
    camInited = _camInited;
    if(camInited){
        [self setCamIsIniting:NO];
        [self setStatus:@"OK"];
    }
}


-(void)setReferenceCount:(int)_referenceCount{
    if(referenceCount != _referenceCount){        
        referenceCount = _referenceCount;
        
        if(referenceCount <= 0){
            referenceCount = 0;

            //Close the camera
            [self close];
        } else {
            if(![self camInited] && ![self camIsIniting]){
                //Init cam
                [self initCam];
            }
        }
        
    }
}

-(void) initCam{
    [self setCamInited:NO];
    [self setCamIsClosing:NO];
    [self setCamIsIniting:YES];
}

-(void)close{
    [self setCamInited:NO];
    [self setCamIsIniting:NO];
    [self setCamIsClosing:YES];
}

-(void) drawCamera:(NSRect)rect{
	tex->draw(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}
-(void) loadSettingsDict:(NSMutableDictionary*)dict{}
-(void) addPropertiesToSave:(NSMutableDictionary*)dict{}
- (void)update{}
-(void)videoGrabberInit{}
-(NSView *)makeViewInRect:(NSRect)rect{return nil;}

@end
