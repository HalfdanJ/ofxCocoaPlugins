//
//  SamplePlugin2.m
//  simpleExample
//
//  Created by Jonas Jongejan on 06/12/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "SamplePlugin2.h"


@implementation SamplePlugin2

-(void) setup{
	grabber = new ofVideoGrabber();
	grabber->initGrabber(640,480);
}

-(void) update:(NSDictionary *)drawingInformation{
	grabber->update();
}

-(void) draw:(NSDictionary *)drawingInformation{
	ofSetColor(255, 255, 255);
	ofFill();
	grabber->draw(0,0,1,1);
}


-(void) controlDraw:(NSDictionary *)drawingInformation{
	ofBackground(0,0,0);
	grabber->draw(0,0);
	
}

@end
