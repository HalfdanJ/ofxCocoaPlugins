#import "ExamplePlugin.h"

@implementation ExamplePlugin

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
   ofBackground(255,255,0);

    ofSetColor(255,0,0);
    ofRect( sin(ofGetElapsedTimeMillis() / 1000.0)*0.5+0.5, 0, 100,100);
    
   
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
