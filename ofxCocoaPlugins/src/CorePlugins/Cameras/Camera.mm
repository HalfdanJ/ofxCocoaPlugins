//
//  Camera.mm
//  loadnloop
//
//  Created by LoadNLoop on 27/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Camera.h"
#include "NormalCameraInstance.h"
#include "IIDCCameraInstance.h"


@implementation Camera
@synthesize cameraInstancesRef, cameraInstance, cameraInstancesController, cameraTypesController;


-(id)initWithCameraInstances:(NSMutableDictionary*)dict{
	if([self init]){	
		cameraInstancesRef = [dict retain];
		
        //Bind cameraTypeController
		cameraTypesController = [[[NSDictionaryController alloc] init] retain];
		[cameraTypesController bind:@"contentDictionary" toObject:self withKeyPath:@"cameraInstancesRef" options:nil];
		
        //Bind cameraInstanceController to the appropriate instances of the controllers 
		cameraInstancesController = [[[NSArrayController alloc] init] retain];
		[cameraInstancesController bind:@"contentArray" toObject:cameraTypesController withKeyPath:@"selection.value.controller.instances" options:nil];
        
        //If a new camera is selected, the updateChosenCamera should be called
		[cameraInstancesController addObserver:self forKeyPath:@"selection" options:nil context:@"cameraSelection"];
        
		//No camera selected from start
        cameraInstance = nil;
        
        //Kickstart
        [self updateChosenCamera];
	} 
	return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"cameraSelection"]){
		[self updateChosenCamera];
	}
}

-(void) updateChosenCamera{
	//NSLog(@"updateChosenCamera");
	if(cameraInstance != nil){
        cameraInstance.referenceCount = cameraInstance.referenceCount - 1;
	}
	
	cameraInstance = [[cameraInstancesController selectedObjects] lastObject] ;
	if(cameraInstance != nil){
        cameraInstance.referenceCount = cameraInstance.referenceCount + 1;	
		
		/*if([cameraInstance objectForKey:@"object"]== nil){
			NSLog(@"New camera instance");
			if([[[[cameraInstancesController selectedObjects] lastObject] objectForKey:@"type"] isEqualToString:@"iidc"]){
				IIDCCameraInstance * cameraObject =  [[IIDCCameraInstance alloc]initWithGuid:[[[cameraInstancesController selectedObjects] lastObject] objectForKey:@"guid"]];
				[cameraObject setCameraInstances:cameraInstancesRef];
                //	NSLog(@"Camera instance ref: %@", cameraInstancesRef);
                
				[cameraInstance setObject:cameraObject forKey:@"object"];
			} else if([[[[cameraInstancesController selectedObjects] lastObject] objectForKey:@"type"] isEqualToString:@"normal"]){
				NormalCameraInstance * cameraObject =  [[NormalCameraInstance alloc]initWithGuid:[[[cameraInstancesController selectedObjects] lastObject] objectForKey:@"guid"] named:[[[cameraInstancesController selectedObjects] lastObject] objectForKey:@"desc"] ];
				[cameraObject setCameraInstances:cameraInstancesRef];
				//	NSLog(@"Camera instance ref: %@", cameraInstancesRef);
				
				[cameraInstance setObject:cameraObject forKey:@"object"];
			} else {
				NSLog(@"Error: Camera type not defined");	
			}
		} */
		
		NSView * newView =    [cameraInstance  makeViewInRect:NSMakeRect(0, 0, [subview bounds].size.width, [subview bounds].size.height)];
        if(newView != nil){
		[subview setSubviews:[NSArray arrayWithObject:newView]];
        } else {
            [subview setSubviews:[NSArray array]];	
        }
		
	} else {
		[subview setSubviews:[NSArray array]];	
	}    
}

-(void)setup{
	//[self videoGrabberInit];	
}

-(void)update{
    if(cameraInstance != nil){
    	[cameraInstance update];
    }
}

-(void) draw:(NSRect)rect{
	if(cameraInstance != nil){
		[cameraInstance drawCamera:rect];
	}
}

-(NSView*) makeViewInRect:(NSRect)rect{
	NSView * view = [[NSView alloc] initWithFrame:rect];
	
	
	NSTextField * nameTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 456, 134, 17)];
	[nameTextField setStringValue:@"No Name"];
	[nameTextField setEditable:NO];	[nameTextField setBordered:NO];	[nameTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]]; 
	[nameTextField setTextColor:[NSColor whiteColor]];
	[nameTextField bind:@"value" toObject:cameraInstancesController withKeyPath:@"selection.name" options:nil];
	[view addSubview:nameTextField];
	
	NSTextField * statusTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(129, 456, 140, 17)];
	[statusTextField setStringValue:@"No status"];
	[statusTextField setEditable:NO];	[statusTextField setBordered:NO];	[statusTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]]; 
	[statusTextField setTextColor:[NSColor whiteColor]];
	[statusTextField setAlignment:NSRightTextAlignment];
	[statusTextField bind:@"value" toObject:cameraInstancesController withKeyPath:@"selection.status" options:nil];
	[view addSubview:statusTextField];
	
	NSButton * enableButton = [[NSButton alloc] initWithFrame:NSMakeRect(278, 455, 18, 18)];
	[enableButton setBezelStyle: NSTexturedSquareBezelStyle];
	[enableButton setButtonType: NSSwitchButton];
	[enableButton bind:@"value" toObject:cameraInstancesController withKeyPath:@"selection.enabled" options:nil];
    
	[view addSubview:enableButton];
	
	
	
	NSTextField * typeTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 426, 84, 17)];
	[typeTextField setStringValue:@"Camera type:"];
	[typeTextField setEditable:NO];	[typeTextField setBordered:NO];	[typeTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[view addSubview:typeTextField];
	
	NSPopUpButton * typeDropdown = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(103, 420, 180, 26)];
	[typeDropdown bind:@"contentValues" toObject:cameraTypesController withKeyPath:@"arrangedObjects.key" options:nil];
	[typeDropdown bind:@"selectedIndex" toObject:cameraTypesController withKeyPath:@"selectionIndex" options:nil];
	
	[view addSubview:typeDropdown];
	
	NSTextField * cameraTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(43, 401, 84, 17)];
	[cameraTextField setStringValue:@"Camera:"];
	[cameraTextField setEditable:NO];	[cameraTextField setBordered:NO];	[cameraTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]];	
	[view addSubview:cameraTextField];
	
	NSPopUpButton * cameraDropdown = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(103, 394, 180, 26)];
	[cameraDropdown bind:@"contentValues" toObject:cameraInstancesController withKeyPath:@"arrangedObjects.name" options:nil];
	[cameraDropdown bind:@"selectedIndex" toObject:cameraInstancesController withKeyPath:@"selectionIndex" options:nil];
	[view addSubview:cameraDropdown];
	
	
	subview = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, rect.size.width, rect.size.height)] retain];
	if(cameraInstance != nil){
		NSView * newView =    [cameraInstance makeViewInRect:NSMakeRect(0, 0, [subview bounds].size.width, [subview bounds].size.height)];
		[subview addSubview:newView];
	}
	[view addSubview:subview];
	
	return view;
}

-(BOOL) isFrameNew{
	if(cameraInstance != nil){
		//NSLog(@"Bool: %i",[[cameraInstance objectForKey:@"object"] isFrameNew]);
		return [cameraInstance isFrameNew];
	}
	return NO;
}

-(NSString *)description{
    return [cameraInstance name];
}

-(ofxCvGrayscaleImage*) cvImage{
    return [cameraInstance cvImage];
}
-(int) width{
    return [cameraInstance width];
}
-(int) height{
    return [cameraInstance height];
}
@end
