#pragma once
#import "GLee.h"

#import <Cocoa/Cocoa.h>

@class PluginManagerController;
@interface SaveManager : NSObject {
	IBOutlet PluginManagerController * controller;
	IBOutlet NSTreeController * pluginsTreeController;

	NSKeyedArchiver * archiver;
	NSMutableData *data;
	NSMutableDictionary * saveDictionary;

	NSString * dataPath;
}
@property (retain) NSString * dataPath;

- (IBAction) saveDataToDisk:(id)sender;
- (IBAction) saveAsDataToDisk:(id)sender;
- (IBAction) loadDataFromDisk:(id)sender;
- (IBAction) loadLastDataFromDisk:(id)sender;

@end
