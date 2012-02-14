#include "GL/glew.h"

#import "SaveManager.h"
#include "ofMain.h"
#include "PluginManagerController.h"
#include "Plugin.h"

@implementation SaveManager
@synthesize dataPath;

-(id) init{
	if(self = [super init]){		
		NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
		[self setDataPath:[userDefaults valueForKey:@"SavePath"]];
		
		saveDictionary = [[NSMutableDictionary dictionary] retain];		
	}
	return self;
}

//
//------
//


- (IBAction) saveAsDataToDisk:(id)sender{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
	NSSavePanel *sp;
	int runResult;
	
	sp = [NSSavePanel savePanel];
	[sp setRequiredFileType:@"of"];
	runResult = [sp runModal];
	if (runResult == NSOKButton) {
		[self setDataPath:[sp filename]];
		[userDefaults setValue:[self dataPath] forKey:@"SavePath"];
        [self saveDataToDisk:self];
	}
}

//
//------
//

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
                [plugin willSave];
				[archiver encodeObject:[plugin enabled] forKey:[NSString stringWithFormat:@"%@Enabled", [plugin name]]];
				[archiver encodeObject:[plugin properties] forKey:[NSString stringWithFormat:@"%@Properties", [plugin name]]];
                
				[archiver encodeObject:[plugin customProperties] forKey:[NSString stringWithFormat:@"%@CustomProperties", [plugin name]]];
				
			}
		}
		
		[archiver finishEncoding];
		
		[data writeToFile:[self dataPath] atomically:YES];	
		
		[archiver release];
		
		[[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"icon"] forFile:[self dataPath] options:0];
	} else {
		[self saveAsDataToDisk:sender];
	}
	
}

//
//------
//


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


//
//------
//


- (IBAction) loadLastDataFromDisk:(id)sender{
	if([self dataPath] != nil){
		data = [[NSMutableData alloc] initWithContentsOfFile:[self dataPath]];
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
                    
					[plugin willChangeValueForKey:@"properties"];
					NSString * key;
					for(key in [tempDict allKeys]){
                        
						//Go through all the properties in the temporary dictionary, and replace the ones in the real plugin
						PluginProperty *  prop = [[plugin properties] objectForKey:key];
						PluginProperty *  loadedProp = [tempDict objectForKey:key];
						if(prop != nil){
							[prop setValue:[loadedProp value]];
							if([prop midiNumber] == nil)
								[prop setMidiNumber:[loadedProp midiNumber]];
							if([prop midiChannel] == nil)
								[prop setMidiChannel:[loadedProp midiChannel]];
						}
					}
					[plugin didChangeValueForKey:@"properties"];
					
					
					//Make a temporary dictionary of the custom propterties
					NSMutableDictionary * tempDict2 = [_unarchiver decodeObjectForKey:[NSString stringWithFormat:@"%@CustomProperties", [plugin name]]];				
					[plugin willChangeValueForKey:@"customProperties"];
                    //  NSLog(@"Custom properties %@",tempDict2);
					for(key in [tempDict2 allKeys]){
						//Go through all the properties in the temporary dictionary, and replace the ones in the real plugin
                        //	id  prop = [[plugin customProperties] objectForKey:key];
                        //	if(prop != nil){						
                        //                        NSLog(@"Key %@",key);
                        [[plugin customProperties] setObject:[tempDict2 objectForKey:key] forKey:key];
                        //	}
					}
					[plugin didChangeValueForKey:@"customProperties"];
                    [plugin customPropertiesLoaded];
                    
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
