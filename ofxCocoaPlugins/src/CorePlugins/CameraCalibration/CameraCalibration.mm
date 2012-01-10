#import "CameraCalibration.h"
#import "Keystoner.h"
#import "CameraCalibrationObject.h"
#import "CameraInstance.h"
#import "KeystoneSurface.h"

@implementation CameraCalibration
@synthesize surfacesArrayController, camerasArrayController, selectedCalibrationObject, changingSurface;

- (id)init{
    self = [super init];
    if (self) {
        camerasArrayController = [[NSArrayController alloc] init];
        surfacesArrayController = [[NSArrayController alloc] init];
        
        [camerasArrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"selection"];
        [surfacesArrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"selection"];
        
        calibrationObjects = [NSMutableDictionary dictionary];
        
        changingSurface = NO;
    }
    
    return self;
}

-(void)initPlugin{
}

//
//----------------
//


-(void)setup{
    Cameras * cameras = GetPlugin(Cameras); 
    [camerasArrayController setContent:[cameras cameras]];
    
    Keystoner * keystoner = GetPlugin(Keystoner); 
    [surfacesArrayController setContent:[keystoner surfaces]];
    
    for(NSString * surface in [keystoner surfaces]){
        NSMutableArray * surfaceCams = [NSMutableArray array];
        
        for(Camera * cam in [cameras cameras]){
            [surfaceCams addObject:[[CameraCalibrationObject alloc] initWithCamera:cam surface:surface]];
        }
        
        [calibrationObjects setObject:surfaceCams forKey:surface];
    }
    
    selectedCalibrationObject = [self calibrationForCamera:[[camerasArrayController selectedObjects] lastObject] surface:[[surfacesArrayController selectedObjects] lastObject]];
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
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    CameraCalibrationObject* selectedCalib = [self selectedCalibrationObject];
    KeystoneSurface * surface = [GetPlugin(Keystoner) getSurface:[selectedCalib surface] viewNumber:0 projectorNumber:0];
    
    ofEnableAlphaBlending();
	
	controlWidth = ofGetWidth();
	controlHeight = ofGetHeight();
	
    float controlAspect = (float) controlWidth / controlHeight;   
    float camAspect = [[[selectedCalib camera] cameraInstance] aspect];
    float surfaceAspect = [[surface aspect] floatValue];
    
    if([self changingSurface]){
        glPushMatrix();
        if(controlAspect > surfaceAspect){
            glTranslated(controlWidth*0.5,0,0);
            glScaled(controlHeight, controlHeight,1);           
            glTranslated(-0.5*surfaceAspect,0,0);
        } else {
            glScaled(controlWidth/surfaceAspect, controlWidth/surfaceAspect,1);           
        }
        
        ofSetColor(0,0,0);
        ofFill();
        ofRect(0,0,surfaceAspect,1);
        
        [surface drawGridSimple:YES];

    } else {
        //Draw cameraf
        
        glPushMatrix();
        if(controlAspect > camAspect){
            glTranslated(controlWidth*0.5,0,0);
            glScaled(controlHeight*camAspect, controlHeight,1);           
            glTranslated(-0.5*1.0,0,0);
        } else {
            glScaled(controlWidth, controlWidth/camAspect,1);           
        }
        [[selectedCalib camera] draw:NSMakeRect(0, 0, 1, 1)];
        
        
    }
    glPopMatrix();

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*)context isEqualToString:@"selection"]){
        [self willChangeValueForKey:@"selectedCalibrationObject"];
        selectedCalibrationObject = [self calibrationForCamera:[[camerasArrayController selectedObjects] lastObject] surface:[[surfacesArrayController selectedObjects] lastObject]];
        [self didChangeValueForKey:@"selectedCalibrationObject"];
    }
    
}

-(CameraCalibrationObject *) calibrationForCamera:(Camera*)camera surface:(NSString*)surface{
    for(CameraCalibrationObject * obj in [calibrationObjects objectForKey:surface]){
        if([obj camera] == camera){
            return obj;
        }
    }
    return nil;
}

@end
