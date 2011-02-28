//
//  QLabController.mm
//  malpais
//
//  Created by Jonas Jongejan on 27/02/11.
//  Copyright 2011 HalfdanJ. All rights reserved.
//

#import "QLabController.h"
#include "QLab.h"


@implementation QLabController
@synthesize cues, linkedProperty;

-(void) startQlabTransaction:(PluginProperty*)proptery{
	[self setLinkedProperty:proptery];
	
	QLabApplication *qLab = [SBApplication applicationWithBundleIdentifier:@"com.figure53.Qlab.2"]; 
	NSArray *workspaces = [qLab workspaces];
	QLabWorkspace * workspace = [workspaces objectAtIndex:0];
	
	NSMutableArray * c = [NSMutableArray array];
	
	for(QLabCue * cue in [workspace cues]){
		NSString *searchString = [NSString stringWithFormat:@"%@: %@", [proptery pluginName], [proptery name]];
		
		NSString *beginsTest = [cue qName];
		NSRange prefixRange = [beginsTest rangeOfString:searchString
												options:(NSAnchoredSearch)];
		
		if(prefixRange.length > 0){
		NSLog(@"Cue %@ %i",[cue qName], prefixRange.length);
			[c addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cue qName],@"name",nil]];
			//[cue set

		}
		//	[cue setQName:@"asdasd¡¡"];
	}
	
	//	QlabCue *cue = [[[qLab classForScriptingClass:@"cue"] alloc] init];
	//	[[workspace cues] addObject:cue];
	//	cue.qName = @"HEHE";
	
	
	[self setCues:c];
	
	[panel orderFront:self];
}
@end
