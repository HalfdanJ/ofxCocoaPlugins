//
//  KeystonePerspective.m
//  ofxCocoaPlugins
//
//  Created by ole kristensen on 15/12/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "KeystonePerspective.h"
#import "KeystoneSurface.h"
#import "Keystoner.h"

@implementation KeystonePerspective
@synthesize applied, surfaceName, viewPoint, scale;

+(KeystonePerspective *) perspectiveWithSurfaceName:(NSString *)surfaceName {

    static KeystonePerspective * perspective = nil;
	perspective = [[KeystonePerspective alloc] initWithSurfaceName:surfaceName];
    
	return perspective;

}

+(KeystonePerspective *)perspectiveWithSurface:(id)surface{
    
	static KeystonePerspective * perspective = nil;
	perspective = [[KeystonePerspective alloc] initWithSurface:surface];
    
	return perspective;
    
}

- (id)init {
    self = [super init];
    if (self) {
        viewPoint = ofVec3f(0,0,0);
        scale = 1.0; // 0-1 fades from orthographic to perspective, but 1.0-2 fades from perspective to flat
    }
    return self;
}

-(KeystonePerspective *)initWithSurfaceName:(NSString*)_surfaceName{
    if([self init]){
        surfaceName = _surfaceName;
    }
    return self;
}


-(KeystonePerspective *)initWithSurface:(id)surface{
    [self initWithSurfaceName:[surface name]];
    return self;
}

-(void)apply{
    if(!applied){
        glPushMatrix();{
            
            KeystoneSurface * mySurface = 
            [GetPlugin(Keystoner) getSurface:surfaceName viewNumber:0 projectorNumber:0];
            // _____________________________________________________^_________________^___
            // surfaces are assumed to have the same aspect in all views on all projectors
            
            float aspect = [[mySurface aspect] floatValue];
                        
            float x = viewPoint.x;
            float y = viewPoint.y;
            float z = fminf(-0.0001,viewPoint.z);
            
            float zFactor = 1.0;
            
            // take care of the scale's two series 0 -> 1 and 1 -> 2 
            if(scale > 1.0){
                zFactor -= fminf(1.0, scale-1.0);
                scale = 1.0;
            } else {
                x -= (1.0-scale)*0.5*aspect;
                y -= (1.0-scale)*0.5;
            }
            
            z = zFactor*(-1/z);
            
            float * multMatrix = new float[16];
            
            multMatrix[0]  = 1.0f;
            multMatrix[1]  = 0.0f;
            multMatrix[2]  = 0.0f;
            multMatrix[3]  = 0.0f;
            multMatrix[4]  = 0.0f;
            multMatrix[5]  = 1.0f;
            multMatrix[6]  = 0.0f;
            multMatrix[7]  = 0.0f;
            multMatrix[8]  = x*z;       // z-axis x shear
            multMatrix[9]  = y*z;       // z-axis y shear
            multMatrix[10] = 1.0f;
            multMatrix[11] = scale*z;   // perspective foreshortening
            multMatrix[12] = 0.0f;
            multMatrix[13] = 0.0f;
            multMatrix[14] = 0.0f;
            multMatrix[15] = 1.0f;
            
            glMultMatrixf(multMatrix);
        }
        applied = YES;
    }
}

-(void)pop{
    if(applied){
        glPopMatrix();
        applied = NO;
    }
}

-(void)setSaveData:(NSDictionary *)dict{
    viewPoint.x = [[dict valueForKey:@"viewPointX"] floatValue];
    viewPoint.y = [[dict valueForKey:@"viewPointY"] floatValue];
    viewPoint.z = [[dict valueForKey:@"viewPointZ"] floatValue];
    scale = [[dict valueForKey:@"scale"] floatValue];
}

-(NSDictionary *)saveData{
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithFloat:viewPoint.x], @"viewPointX",
                           [NSNumber numberWithFloat:viewPoint.y], @"viewPointY",
                           [NSNumber numberWithFloat:viewPoint.z], @"viewPointZ",
                           [NSNumber numberWithFloat:scale], @"scale",
                           nil];
    return dict;
}

@end
