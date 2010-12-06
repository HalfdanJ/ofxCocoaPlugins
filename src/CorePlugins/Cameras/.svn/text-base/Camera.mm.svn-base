//
//  Camera.mm
//  loadnloop
//
//  Created by LoadNLoop on 27/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Camera.h"

#import <BWToolkitFramework/BWToolkitFramework.h>


@implementation Camera
@synthesize cameraInstancesRef, cameraInstance, cameraInstancesController, cameraTypesController;


-(id)initWithCameraInstances:(NSMutableDictionary*)dict{
	if([self init]){	
		cameraInstancesRef = [dict retain];
		
		cameraTypesController = [[[NSDictionaryController alloc] init] retain];
		[cameraTypesController bind:@"contentDictionary" toObject:self withKeyPath:@"cameraInstancesRef" options:nil];
		
		cameraInstancesController = [[[NSArrayController alloc] init] retain];
		[cameraInstancesController bind:@"contentArray" toObject:cameraTypesController withKeyPath:@"selection.value" options:nil];
		
		[cameraInstancesController addObserver:self forKeyPath:@"selection" options:nil context:@"cameraSelection"];
		[self updateChoosedCamera];
	} 
	return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"cameraSelection"]){
		[self updateChoosedCamera];
	}
}

-(void) updateChoosedCamera{
	//NSLog(@"updateChoosedCamera");
	if(cameraInstance != nil){
		[cameraInstance setObject:[NSNumber numberWithInt:[[cameraInstance objectForKey:@"referenceCount"]intValue]-1] forKey:@"referenceCount"];
		if([[cameraInstance objectForKey:@"referenceCount"]intValue] <= 0){
			//Release the camera
		//	[[cameraInstance objectForKey:@"object"] close];
	 
		}
		//	[[cameraInstance objectForKey:@"object"] release];
	}
	
	cameraInstance = [[cameraInstancesController selectedObjects] lastObject] ;
	if(cameraInstance != nil){
		[cameraInstance setObject:[NSNumber numberWithInt:[[cameraInstance objectForKey:@"referenceCount"]intValue]+1] forKey:@"referenceCount"];
		
		
		if([cameraInstance objectForKey:@"object"]== nil){
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
		} 
		
		NSView * newView =    [[cameraInstance objectForKey:@"object"] makeViewInRect:NSMakeRect(0, 0, [subview bounds].size.width, [subview bounds].size.height)];
		[subview setSubviews:[NSArray arrayWithObject:newView]];
		
	} else {
		[subview setSubviews:[NSArray array]];	
	}
}

-(void)setup{
	//[self videoGrabberInit];	
}

-(void)update{
//	if(cameraInstance != nil){
//		[[cameraInstance objectForKey:@"object"] update];
//	 }
}

-(void) draw:(NSRect)rect{
	if(cameraInstance != nil){
		[[cameraInstance objectForKey:@"object"] drawCamera:rect];
	}
}

-(NSView*) makeViewInRect:(NSRect)rect{
	NSView * view = [[NSView alloc] initWithFrame:rect];
	
	
	NSTextField * nameTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 456, 134, 17)];
	[nameTextField setStringValue:@"No Name"];
	[nameTextField setEditable:NO];	[nameTextField setBordered:NO];	[nameTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]]; 
	[nameTextField setTextColor:[NSColor whiteColor]];
	[nameTextField bind:@"value" toObject:cameraInstancesController withKeyPath:@"selection.object.name" options:nil];
	[view addSubview:nameTextField];
	
	NSTextField * statusTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(129, 456, 140, 17)];
	[statusTextField setStringValue:@"No status"];
	[statusTextField setEditable:NO];	[statusTextField setBordered:NO];	[statusTextField setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0]]; 
	[statusTextField setTextColor:[NSColor whiteColor]];
	[statusTextField setAlignment:NSRightTextAlignment];
	[statusTextField bind:@"value" toObject:cameraInstancesController withKeyPath:@"selection.object.status" options:nil];
	[view addSubview:statusTextField];
	
	NSButton * enableButton = [[NSButton alloc] initWithFrame:NSMakeRect(278, 455, 18, 18)];
	[enableButton setBezelStyle: NSTexturedSquareBezelStyle];
	[enableButton setButtonType: NSSwitchButton];
	[enableButton bind:@"value" toObject:cameraInstancesController withKeyPath:@"selection.object.enabled" options:nil];

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
		NSView * newView =    [[cameraInstance objectForKey:@"object"] makeViewInRect:NSMakeRect(0, 0, [subview bounds].size.width, [subview bounds].size.height)];
		[subview addSubview:newView];
	}
	[view addSubview:subview];
	
	return view;
}

-(BOOL) isFrameNew{
	if(cameraInstance != nil){
		//NSLog(@"Bool: %i",[[cameraInstance objectForKey:@"object"] isFrameNew]);
		return [[cameraInstance objectForKey:@"object"] isFrameNew];
	}
	return NO;
}



@end
