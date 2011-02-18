//
//  SaveManager.mm
//  simpleExample
//
//  Created by LoadNLoop on 18/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SaveManager.h"
#include "ofMain.h";
#include "PluginManagerController.h"
#include "Plugin.h"

@implementation SaveManager
@synthesize dataPath;

-(id) init{
	if([super init]){
		
		NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
		[self setDataPath:[userDefaults valueForKey:@"SavePath"]];
		
		
		saveDictionary = [[NSMutableDictionary dictionary] retain];
		
	}
	return self;
}

- (void) awakeFromNib
{
}

- (IBAction) saveAsDataToDisk:(id)sender{
	NSSavePanel *sp;
	int runResult;
	
	sp = [NSSavePanel savePanel];
	[sp setRequiredFileType:@"of"];
	runResult = [sp runModal];
	if (runResult == NSOKButton) {
		[self setDataPath:[sp filename]];
		NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setValue:[self dataPath] forKey:@"SavePath"];
	}
}

- (IBAction) saveDataToDisk:(id)sender{
	if([self dataPath] != nil){
		NSLog(@"Save file: %@",[self dataPath]);
		data = [[NSMutableData data] retain];
		
		archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver setOutputFormat: NSPropertyListXMLFormat_v1_0];
		
		
		[archiver encodeObject:[pluginsTreeController selectionIndexPath] forKey:@"SelectionPath"];
		
		NSDictionary * group;
		for(group in [controller plugins]){
			ofPlugin * plugin;
			for(plugin in [group objectForKey:@"children"]){
				[archiver encodeObject:[plugin enabled] forKey:[NSString stringWithFormat:@"%@Enabled", [plugin name]]];
				[archiver encodeObject:[plugin properties] forKey:[NSString stringWithFormat:@"%@Properties", [plugin name]]];
				//NSLog(@"Save %@",[plugin customProperties]);
				[archiver encodeObject:[plugin customProperties] forKey:[NSString stringWithFormat:@"%@CustomProperties", [plugin name]]];
				
			}
		}
		
		
		
		
		
		[archiver finishEncoding];
		
		[data writeToFile:[self dataPath] atomically:YES];	
		
		[archiver release];
	} else {
		[self saveAsDataToDisk:sender];
	}
	
}

- (IBAction) loadDataFromDisk:(id)sender{
	NSOpenPanel * op;
	op = [NSOpenPanel openPanel];
	[op setRequiredFileType:@"of"];
	int runResult;
	runResult = [op runModal];
	if (runResult == NSOKButton) {
		[self setDataPath:[op filename]];
		NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setValue:[self dataPath] forKey:@"SavePath"];
		
		[self loadLastDataFromDisk:sender];
		
	}
}

- (IBAction) loadLastDataFromDisk:(id)sender{
	if([self dataPath] != nil){
		data = [[NSData alloc] initWithContentsOfFile:[self dataPath]];
		if(data != nil){
			NSLog(@"Load file: %@",[self dataPath]);
			NSKeyedUnarchiver * _unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			
			[pluginsTreeController setSelectionIndexPath:[_unarchiver decodeObjectForKey:@"SelectionPath"]];

			NSDictionary * group;
			for(group in [controller plugins]){
				ofPlugin * plugin;
				for(plugin in [group objectForKey:@"children"]){
					[plugin setEnabled:[_unarchiver decodeObjectForKey:[NSString stringWithFormat:@"%@Enabled", [plugin name]]]];
					
					//Make a temporary dictionary of the propterties
					NSMutableDictionary * tempDict = [[_unarchiver decodeObjectForKey:[NSString stringWithFormat:@"%@Properties", [plugin name]]] retain];
				
					cout<<[[plugin name] cString]<<endl;
					[plugin willChangeValueForKey:@"properties"];
					NSString * key;
					for(key in [tempDict allKeys]){

						//Go through all the properties in the temporary dictionary, and replace the ones in the real plugin
						PluginProperty *  prop = [[plugin properties] objectForKey:key];
						PluginProperty *  loadedProp = [tempDict objectForKey:key];
						if(prop != nil){
//							if([[prop name] isEqualToString:@"textScale"]){
								cout<<"  --- Load "<<[key cString]<<" to "<<[[plugin name] cString]<<" value "<<[[loadedProp value] floatValue]<<endl;
//							}*
							[prop setValue:[loadedProp value]];
							if([prop midiNumber] == nil)
								[prop setMidiNumber:[loadedProp midiNumber]];
							if([prop midiChannel] == nil)
								[prop setMidiChannel:[loadedProp midiChannel]];
						//	[[plugin properties] setObject:[tempDict objectForKey:key] forKey:key];
						}
					}
					[plugin didChangeValueForKey:@"properties"];
					
					
					//Make a temporary dictionary of the custom propterties
					NSMutableDictionary * tempDict2 = [_unarchiver decodeObjectForKey:[NSString stringWithFormat:@"%@CustomProperties", [plugin name]]];				
					[plugin willChangeValueForKey:@"customProperties"];
					for(key in [tempDict2 allKeys]){
						//Go through all the properties in the temporary dictionary, and replace the ones in the real plugin
						id  prop = [[plugin customProperties] objectForKey:key];

						if(prop != nil){							
							
							[[plugin customProperties] setObject:[tempDict2 objectForKey:key] forKey:key];
									//				NSLog(@"Load props %@",[plugin customProperties]);					
						}
					}
					[plugin didChangeValueForKey:@"customProperties"];
					
					[tempDict release];		
				}
			}
		 
			[_unarchiver finishDecoding];
			[_unarchiver release];

		}	
		[data release];
	}
}


@end
