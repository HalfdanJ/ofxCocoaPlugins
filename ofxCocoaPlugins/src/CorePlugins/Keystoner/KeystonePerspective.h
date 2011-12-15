//
//  KeystonePerspective.h
//  ofxCocoaPlugins
//
//  Created by ole kristensen on 15/12/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeystoneSurface.h"

@interface KeystonePerspective : NSObject {

    NSString * surfaceName;
    
    ofVec3f viewPoint;
    
    float scale; 
    //    ^ 0-1 fades from orthographic to perspective, 
    //      but 1.0-2 fades from perspective to flat
    
    BOOL applied;
    
}

@property (assign) BOOL applied;
@property (assign) float scale;
@property (assign) ofVec3f viewPoint;
@property (readonly) NSString* surfaceName;

+(KeystonePerspective*) perspectiveWithSurface:(KeystoneSurface*)surface;
+(KeystonePerspective*) perspectiveWithSurfaceName:(NSString*)surfaceName;
-(KeystonePerspective*) initWithSurface:(KeystoneSurface*)surface;
-(KeystonePerspective*) initWithSurfaceName:(NSString*)_surfaceName;

-(void) apply;
-(void) pop;

-(void)setSaveData:(NSDictionary*)dict;
-(NSDictionary*)saveData;

@end
