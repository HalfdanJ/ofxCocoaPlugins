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


-(id)initWithGuid:(NSString*)_guid named:(NSString*)_name{
	if([self init]){
		[self setGuid:_guid];
        [self setStatus:@"Found"];

				
		[self setName:_name];
	}
	return self;
}


-(NSView *) makeViewInRect:(NSRect)rect{
	NSView * view = [[NSView alloc]initWithFrame:rect];
	return view;
}

-(void) update{
    if([self camIsIniting]){
        grabber = new ofVideoGrabber();
        grabber->setDeviceID([[self guid] intValue]);
        
        if(grabber->initGrabber(800, 600, true)){
            [self setCamInited:YES];
        } else {
            [self setCamIsConnected:NO];
        }
        tex = &grabber->getTextureReference();
    }
    if(grabber != nil){
	grabber->update();
	tex = &grabber->getTextureReference();
    }

}

@end
