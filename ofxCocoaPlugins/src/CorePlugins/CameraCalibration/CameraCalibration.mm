#import "CameraCalibration.h"
#import "Keystoner.h"
#import "CameraCalibrationObject.h"
#import "CameraInstance.h"
#import "KeystoneSurface.h"
#include "TextureGrid.h"

@implementation CameraCalibration
@synthesize surfacesArrayController, camerasArrayController, selectedCalibrationObject, changingSurface, calibrationObjects, drawDebug;

- (id)init{
    self = [super init];
    if (self) {
        camerasArrayController = [[NSArrayController alloc] init];
        surfacesArrayController = [[NSDictionaryController alloc] init];
        
        [camerasArrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"selectionCam"];
        [surfacesArrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"selectionSurf"];
        
        calibrationObjects = [NSMutableDictionary dictionary];
        
        changingSurface = NO;
    }
    
    return self;
}

-(void)initPlugin{
    Cameras * cameras = GetPlugin(Cameras); 
    Keystoner * keystoner = GetPlugin(Keystoner); 
    
    for(NSString * surface in [keystoner surfaces]){
        NSMutableArray * surfaceCams = [NSMutableArray array];
        KeystoneSurface * surfaceObj = [GetPlugin(Keystoner) getSurface:surface viewNumber:0 projectorNumber:0];
        
        
        for(Camera * cam in [cameras cameras]){
            [surfaceCams addObject:[[CameraCalibrationObject alloc] initWithCamera:cam surface:surfaceObj]];
        }
        
        [calibrationObjects setObject:surfaceCams forKey:surface];
    }

    [surfacesArrayController bind:@"contentDictionary" toObject:self withKeyPath:@"self.calibrationObjects" options:nil];
    
    [self bind:@"selectedCalibrationObject" toObject:camerasArrayController withKeyPath:@"selection.self" options:nil];
}

//
//----------------
//


-(void)setup{
    //Handle image
    NSBundle *framework=[NSBundle bundleForClass:[self class]];
    NSString * path = [framework pathForResource:@"handle" ofType:@"png"];
    handleImage = new ofImage();
    bool imageLoaded = handleImage->loadImage([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if(!imageLoaded){
        NSLog(@"Handle image not found in cameraCalibration!!");
    }
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    for(NSString * surfaceKey in calibrationObjects){
        NSArray * ourArr = [calibrationObjects objectForKey:surfaceKey];
        
        for(CameraCalibrationObject * obj in ourArr){
            if([[[obj camera] cameraInstance] camInited]){
                [obj newFrame];
            }
        }
    }
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    CameraCalibrationObject* selectedCalib = [self selectedCalibrationObject];
    KeystoneSurface * surface = [selectedCalib surface];
    CameraInstance * camInstance = [[selectedCalib camera] cameraInstance];

    if([self changingSurface]){
        glPushMatrix();
        [GetPlugin(Keystoner) applySurface:surface];
        
        //Draw handles
        {
            float hw = 0.05;
            float hh = hw;
            
            ofSetColor(150, 255, 150);
            handleImage->draw([selectedCalib projHandle:0].x-hw*0.5,[selectedCalib projHandle:0].y - hh*0.5, hw, hh);
            
            ofSetColor(255, 150, 150);
            handleImage->draw([selectedCalib projHandle:1].x-hw*0.5,[selectedCalib projHandle:1].y - hh*0.5, hw, hh);
            
            ofSetColor(150, 150, 255);
            handleImage->draw([selectedCalib projHandle:2].x-hw*0.5,[selectedCalib projHandle:2].y - hh*0.5, hw, hh);
            
            ofSetColor(255, 255, 100);
            handleImage->draw([selectedCalib projHandle:3].x-hw*0.5,[selectedCalib projHandle:3].y - hh*0.5, hw, hh);         
            
        }
        

        [GetPlugin(Keystoner) popSurface];
        glPopMatrix();
    } else if([self drawDebug]){
        
        if([camInstance camInited]){
            glPushMatrix();
            [GetPlugin(Keystoner) applySurface:surface];
            ofFill();
            
            {
                glPushMatrix();
                //The surface corners
                ofVec2f poly[4];                
                poly[0] = ofVec2f(0.0,0.0);
                poly[1] = ofVec2f([selectedCalib surfaceAspect],0.0);
                poly[2] = ofVec2f([selectedCalib surfaceAspect],1.0);
                poly[3] = ofVec2f(0.0,1.0);
                
                //The surface corners in camera space
                ofVec2f corners[4];                
                for(int i=0;i<4;i++){
                    corners[i] = [selectedCalib surfaceCorner:i] * ofVec2f([camInstance width], [camInstance height]);
                }
                
                
                ofSetColor(255,255,255);
                TextureGrid texGrid;
                texGrid.drawTextureGrid([camInstance tex],  poly, corners, 10);
                glPopMatrix();
            }
            
            //Draw handles
            {
                float hw = 0.05;
                float hh = hw;
                
                ofSetColor(150, 255, 150);
                handleImage->draw([selectedCalib projHandle:0].x-hw*0.5,[selectedCalib projHandle:0].y - hh*0.5, hw, hh);
                
                ofSetColor(255, 150, 150);
                ofRect([selectedCalib projHandle:0].x-hw*0.5,[selectedCalib projHandle:0].y - hh*0.5, hw, hh);
                handleImage->draw([selectedCalib projHandle:1].x-hw*0.5,[selectedCalib projHandle:1].y - hh*0.5, hw, hh);
                
                ofSetColor(150, 150, 255);
                handleImage->draw([selectedCalib projHandle:2].x-hw*0.5,[selectedCalib projHandle:2].y - hh*0.5, hw, hh);
                
                ofSetColor(255, 255, 100);
                handleImage->draw([selectedCalib projHandle:3].x-hw*0.5,[selectedCalib projHandle:3].y - hh*0.5, hw, hh);         
            
            }
            
            //Draw border
            {
                ofSetColor(255,0,0);
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
                glBegin(GL_POLYGON);
                glVertex2d([selectedCalib cameraToSurface:ofVec2f(0,0)].x, [selectedCalib cameraToSurface:ofVec2f(0,0)].y);    
                glVertex2d([selectedCalib cameraToSurface:ofVec2f(1,0)].x, [selectedCalib cameraToSurface:ofVec2f(1,0)].y);    
                glVertex2d([selectedCalib cameraToSurface:ofVec2f(1,1)].x, [selectedCalib cameraToSurface:ofVec2f(1,1)].y);    
                glVertex2d([selectedCalib cameraToSurface:ofVec2f(0,1)].x, [selectedCalib cameraToSurface:ofVec2f(0,1)].y);    
                glEnd();
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            }

            
            [GetPlugin(Keystoner) popSurface];
            glPopMatrix();
        }
    }
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    CameraCalibrationObject* selectedCalib = [self selectedCalibrationObject];
    KeystoneSurface * surface = [selectedCalib surface];
    
    ofEnableAlphaBlending();
	
	controlWidth = ofGetWidth();
	controlHeight = ofGetHeight();
	
    float controlAspect = (float) controlWidth / controlHeight;   
    float camAspect = [[[selectedCalib camera] cameraInstance] aspect];
    float surfaceAspect = [[surface aspect] floatValue];
    
    if([self changingSurface]){
        ofSetColor(255,255,255);
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
        
        //Draw handles
        {
            float hw = 0.05;
            float hh = hw;
            
            ofSetColor(0, 255, 0);
            handleImage->draw([selectedCalib projHandle:0].x-hw*0.5,[selectedCalib projHandle:0].y - hh*0.5, hw, hh);
            
            ofSetColor(255, 0, 0);
            handleImage->draw([selectedCalib projHandle:1].x-hw*0.5,[selectedCalib projHandle:1].y - hh*0.5, hw, hh);
            
            ofSetColor(0, 0, 255);
            handleImage->draw([selectedCalib projHandle:2].x-hw*0.5,[selectedCalib projHandle:2].y - hh*0.5, hw, hh);
            
            ofSetColor(255, 255, 0);
            handleImage->draw([selectedCalib projHandle:3].x-hw*0.5,[selectedCalib projHandle:3].y - hh*0.5, hw, hh);         
        }
        
    } else {
        //Draw camera
        ofSetColor(255,255,255);
        glPushMatrix();
        if(controlAspect > camAspect){
            glTranslated(controlWidth*0.5,0,0);
            glScaled(controlHeight*camAspect, controlHeight,1);           
            glTranslated(-0.5*1.0,0,0);
        } else {
            glScaled(controlWidth, controlWidth/camAspect,1);           
        }
        [[selectedCalib camera] draw:NSMakeRect(0, 0, 1, 1)];
        
        //Draw handles
        {
            float hw = 0.03;
            float hh = hw*camAspect;
            
            ofSetColor(0, 255, 0);
            handleImage->draw([selectedCalib camHandle:0].x-hw*0.5,[selectedCalib camHandle:0].y - hh*0.5, hw, hh);
            
            ofSetColor(255, 0, 0);
            handleImage->draw([selectedCalib camHandle:1].x-hw*0.5,[selectedCalib camHandle:1].y - hh*0.5, hw, hh);
            
            ofSetColor(0, 0, 255);
            handleImage->draw([selectedCalib camHandle:2].x-hw*0.5,[selectedCalib camHandle:2].y - hh*0.5, hw, hh);
            
            ofSetColor(255, 255, 0);
            handleImage->draw([selectedCalib camHandle:3].x-hw*0.5,[selectedCalib camHandle:3].y - hh*0.5, hw, hh);
            
        }
        
        //Draw surface
        {
            ofSetColor(255,255,0);
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glBegin(GL_POLYGON);
            for(int i=0;i<4;i++){
                glVertex2d([selectedCalib surfaceCorner:i].x, [selectedCalib surfaceCorner:i].y);    
            }           
            glEnd();
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }
        
        
    }
    glPopMatrix();
    
}

#pragma mark Saving 
-(void)customPropertiesLoaded{		
    NSLog(@"Set Custom Properties: %@ %u",customProperties,[[customProperties objectForKey:@"instances"] count]);
    int u=0;
    for(NSString * surfaceKey in calibrationObjects){
        NSArray * ourArr = [calibrationObjects objectForKey:surfaceKey];
        NSArray * savedArr = [[customProperties objectForKey:@"instances"] objectForKey:surfaceKey];
        
        for(CameraCalibrationObject * obj in ourArr){
            if([savedArr count] > u){
                NSMutableDictionary * dict = [savedArr objectAtIndex:u];
                
                [obj setActive:[[dict objectForKey:@"active"] boolValue]];
                
                for(int i=0;i<4;i++){
                    ofVec2f projPoint = ofVec2f([[dict objectForKey:[NSString stringWithFormat:@"projHandle%ix",i]] floatValue],[[dict objectForKey:[NSString stringWithFormat:@"projHandle%iy",i]] floatValue] );
                    [obj setProjHandle:i to:projPoint];
                    
                    ofVec2f camPoint = ofVec2f([[dict objectForKey:[NSString stringWithFormat:@"camHandle%ix",i]] floatValue],[[dict objectForKey:[NSString stringWithFormat:@"camHandle%iy",i]] floatValue] );
                    [obj setCamHandle:i to:camPoint];                    
                }               
            }
            u++;
        }
    }
    
}

-(void)willSave{	//Read the settings of the selected cameras
	
	NSMutableDictionary * dict = customProperties;
    
    NSMutableDictionary * camerasArray = [NSMutableDictionary dictionary];
    for(NSString * surfaceKey in calibrationObjects){
        NSArray * ourArr = [calibrationObjects objectForKey:surfaceKey];
        NSMutableArray * saveArr = [NSMutableArray array];
        
        for(CameraCalibrationObject * obj in ourArr){
            NSMutableDictionary * props = [NSMutableDictionary dictionary];
            
            [props setObject:[NSNumber numberWithBool:[obj active]] forKey:@"active"];
            
            for(int i=0;i<4;i++){
                [props setObject:[NSNumber numberWithFloat:[obj projHandle:i].x] 
                          forKey:[NSString stringWithFormat:@"projHandle%ix",i]];               
                [props setObject:[NSNumber numberWithFloat:[obj projHandle:i].y] 
                          forKey:[NSString stringWithFormat:@"projHandle%iy",i]];               
                
                [props setObject:[NSNumber numberWithFloat:[obj camHandle:i].x] 
                          forKey:[NSString stringWithFormat:@"camHandle%ix",i]];               
                [props setObject:[NSNumber numberWithFloat:[obj camHandle:i].y] 
                          forKey:[NSString stringWithFormat:@"camHandle%iy",i]];    
            }
            
            
            [saveArr addObject:props];
        }
        
        
        [camerasArray setObject:saveArr forKey:surfaceKey];
    }
    
    [dict setObject:camerasArray forKey:@"instances"];
}



#pragma mark Selection etc
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*)context isEqualToString:@"selectionSurf"]){
        NSString * key = [[[surfacesArrayController selectedObjects]lastObject] key];
        [camerasArrayController setContent:[calibrationObjects objectForKey:key]];
        
        NSLog(@"Sel %@",[calibrationObjects objectForKey:key]);
        //        [self willChangeValueForKey:@"selectedCalibrationObject"];
/*        NSLog(@" %@ %@", [[camerasArrayController selection] valueForKey:@"self"], [[surfacesArrayController selection] valueForKey:@"self"]);
        int camIndex = [camerasArrayController selectionIndex];
        int surfIndex = [surfacesArrayController selectionIndex];
        
        if(surfIndex >= 0 && surfIndex < 100 && camIndex >= 0 && camIndex <= 100){
            NSString * surface = [[surfacesArrayController arrangedObjects] objectAtIndex:surfIndex];
            CameraCalibrationObject * obj = [[calibrationObjects objectForKey:surface] objectAtIndex:camIndex];
            
            
            [self setSelectedCalibrationObject:obj];
        }
        //        [self didChangeValueForKey:@"selectedCalibrationObject"];*/
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


#pragma mark Mouse stuff

-(ofVec2f) transformMouse:(ofVec2f)mouse{
    CameraCalibrationObject* selectedCalib = [self selectedCalibrationObject];
    KeystoneSurface * surface = [selectedCalib surface];
    
    float controlAspect = (float) controlWidth / controlHeight;   
    float camAspect = [[[selectedCalib camera] cameraInstance] aspect];
    float surfaceAspect = [[surface aspect] floatValue];
    
    if([self changingSurface]){
        if(controlAspect > surfaceAspect){
            //            glTranslated(controlWidth*0.5,0,0);
            mouse -= ofVec2f(controlWidth*0.5,0);
            //            glScaled(controlHeight, controlHeight,1);           
            mouse /= ofVec2f(controlHeight, controlHeight);            
            //            glTranslated(-0.5*surfaceAspect,0,0);
            mouse -= ofVec2f(-0.5*surfaceAspect,0);
        } else {
            //            glScaled(controlWidth/surfaceAspect, controlWidth/surfaceAspect,1);           
            mouse /= ofVec2f(controlWidth/surfaceAspect, controlWidth/surfaceAspect);            
        }
    } else {
        if(controlAspect > camAspect){
            //            glTranslated(controlWidth*0.5,0,0);
            mouse -= ofVec2f(controlWidth*0.5,0);
            //            glScaled(controlHeight*camAspect, controlHeight,1);           
            mouse /= ofVec2f(controlHeight*camAspect, controlHeight);            
            //            glTranslated(-0.5*1.0,0,0);
            mouse -= ofVec2f(-0.5*1.0,0);
        } else {
            //            glScaled(controlWidth, controlWidth/camAspect,1);           
            mouse /= ofVec2f(controlWidth, controlWidth/camAspect);            
        }
    }
    
    return mouse;
}

-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
    CameraCalibrationObject* selectedCalib = [self selectedCalibrationObject];
    
    if(draggedPoint != -1){
        ofVec2f mouse = [self transformMouse:ofVec2f(x,y)];
        
        if([self changingSurface]){
            [selectedCalib setProjHandle:draggedPoint to:mouse];
        } else {
            [selectedCalib setCamHandle:draggedPoint to:mouse];
        }
    } 
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
    
    CameraCalibrationObject* selectedCalib = [self selectedCalibrationObject];
    
    ofVec2f mouse = [self transformMouse:ofVec2f(x,y)];
    
    draggedPoint = -1;
    if([self changingSurface]){
        for(int i=0;i<4;i++){
            if (mouse.distance([selectedCalib projHandle:i]) < 0.035) {
                draggedPoint = i;
                [NSCursor hide];
            }
        }
    } else {
        for(int i=0;i<4;i++){
            if (mouse.distance([selectedCalib camHandle:i]) < 0.035) {
                draggedPoint = i;
                [NSCursor hide];
            }
        }
    }
}

-(void) controlMouseReleased:(float)x y:(float)y{
    draggedPoint = -1;
    
    [NSCursor unhide];
}


@end
