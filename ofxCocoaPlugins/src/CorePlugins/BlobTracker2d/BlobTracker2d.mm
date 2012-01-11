#import "BlobTracker2d.h"
#import "Keystoner.h"
#import "Cameras.h"
#import <ofxCocoaPlugins/CameraCalibration.h>
#import "KeystoneSurface.h"
#ifdef USE_KINECT_2D_TRACKER
#import "Kinect.h"
#endif

@implementation BlobTracker2d

-(void)initPlugin{
    instances = [NSMutableArray array];
    int i=0;

#ifdef USE_KINECT_2D_TRACKER
    for(KinectInstance * kinect in [GetPlugin(Kinect) instances]){
        BlobTrackerInstance2d * newInstance = [[BlobTrackerInstance2d alloc] init];
        [newInstance setCameraInstance:kinect];
        [newInstance setTrackerNumber:i];
        [instances addObject:newInstance];
        i++;
        
        [self addProperty:[BoolProperty boolPropertyWithDefaultvalue:NO] named:[NSString stringWithFormat:@"grab%i", i]];
    }
#endif
    for(Camera * cam in [GetPlugin(Cameras) cameras]){
        BlobTrackerInstance2d * newInstance = [[BlobTrackerInstance2d alloc] init];
        [newInstance setCameraInstance:cam];
        [newInstance setTrackerNumber:i];
        [newInstance setCalibrator:[GetPlugin(CameraCalibration) calibrationForCamera:cam surface:@"Floor"]];
        [instances addObject:newInstance];
        i++;
        
        [self addProperty:[BoolProperty boolPropertyWithDefaultvalue:NO] named:[NSString stringWithFormat:@"grab%i", i]];
        
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    int i=1;
    for(BlobTrackerInstance2d * instance in instances){
        BoolProperty * p = Prop(([NSString stringWithFormat:@"grab%i", i]));
        if(p == object && [p boolValue]){
            [p setBoolValue:NO];
            [[instance learnBackgroundButton] setState:1];           
        }
        i++;
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    int number = [instances count];
    int i=0;
    for(BlobTrackerInstance2d * instance in instances){
        [NSBundle loadNibNamed:@"BlobTrackerInstance2d"  owner:instance];
        if(i==0){
            controlWidth = [[instance view] frame].size.width;
            controlHeight = [[instance view] frame].size.height;
            [[self view] setFrame:NSMakeRect(0,0,controlWidth+800, number*controlHeight)];

        }
        
        [[instance view] setFrame:NSMakeRect([[self view]bounds].origin.x+800, [[self view]bounds].origin.y+controlHeight*(number-i-1), controlWidth, controlHeight)];
        [[self view] addSubview:[instance view]];
        i++;
    }
    
    [[self controlGlView] setFrame:NSMakeRect([[self view]bounds].origin.x, [[self view]bounds].origin.y, 800, controlHeight*number)];    
}

-(void)customPropertiesLoaded{		
    NSLog(@"Set Custom Properties: %@ %u",customProperties,[[customProperties objectForKey:@"instances"] count]);
    int i=0;
    for(BlobTrackerInstance2d * instance in instances){
        if([[customProperties objectForKey:@"instances"] count] > i){
            NSMutableDictionary * dict = [[customProperties objectForKey:@"instances"] objectAtIndex:i];
            [instance setProperties:[dict valueForKey:@"properties"]];
        }
        i++;
    }
}

-(void)willSave{	
	NSMutableArray * camerasArray = [NSMutableArray arrayWithCapacity:[instances count]];
	
	BlobTrackerInstance2d * instance;
	for(instance in instances){
        NSMutableDictionary * props = [NSMutableDictionary dictionary];
        [props setObject:[instance properties] forKey:@"properties"];
        
        [camerasArray addObject:props];
	}
	
	[customProperties setObject:camerasArray forKey:@"instances"];
}



-(void) setup{
    for(BlobTrackerInstance2d * instance in instances){
        [instance setup];
    }
}

-(void)draw:(NSDictionary *)drawingInformation{
    glPushMatrix();{
        for(BlobTrackerInstance2d * instance in instances){
            // [[instance view] setNeedsDisplay:YES];
            
            if([instance isKinect] && [instance drawDebug] ){
                KeystoneSurface * surface = [[instance cameraInstance] surface];
                [GetPlugin(Keystoner) applySurface:surface];            
                [instance drawBlobs:NSMakeRect(0,0,[[surface aspect] floatValue], 1) warped:YES];
                [GetPlugin(Keystoner) popSurface];            

            }
            if(![instance isKinect] && [instance drawDebug] ){
                KeystoneSurface * surface = [[instance calibrator] surface];
                [GetPlugin(Keystoner) applySurface:surface];            
                [instance drawBlobs:NSMakeRect(0,0,[[surface aspect] floatValue], 1) warped:YES];
                [GetPlugin(Keystoner) popSurface];            
                
            }

        }        
    }glPopMatrix();
}


-(void)controlDraw:(NSDictionary *)drawingInformation{
    ofSetColor(0,0,0);
    int blockWidth = 800/3;
    int blockHeight = blockWidth * 3.0/4.0;;

    glPushMatrix();{
        for(BlobTrackerInstance2d * instance in instances){
            ofFill();
            ofSetColor(0,0,0);
            
            ofSetColor(255,255,255);
            [instance drawInput:NSMakeRect(0,0,blockWidth, blockHeight)];
            
            [instance drawSurfaceMask:NSMakeRect(0,0,blockWidth, blockHeight)];
            
            [instance drawBackground:NSMakeRect(blockWidth,0,blockWidth, blockHeight)];
            
            [instance drawDifference:NSMakeRect(blockWidth*2,0,blockWidth, blockHeight)];

            [instance drawBlobs:NSMakeRect(blockWidth*2,0,blockWidth, blockHeight) warped:NO];
            
            glTranslated(0, controlHeight, 0);
        }        
    }glPopMatrix();
}


-(void) update:(NSDictionary *)drawingInformation{
    int i=1;
    for(BlobTrackerInstance2d * instance in instances){

        [instance update:drawingInformation];
        i++;
    }
}

-(BlobTrackerInstance2d*) getInstance:(int) num{
    if(num >= 0 && num < [instances count]){
        return [instances objectAtIndex:num];
    } 
    return nil;
}
@end
