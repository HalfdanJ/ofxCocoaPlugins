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
/*
-(void) assignMidiSettingsForPlugin:(ofPlugin*)plugin{
	QLabApplication *qLab = [SBApplication applicationWithBundleIdentifier:@"com.figure53.Qlab.2"]; 
	NSArray *workspaces = [qLab workspaces];
	QLabWorkspace * workspace = [workspaces objectAtIndex:0];
	
	
	for(QLabCue * cue in [workspace cues]){
		NSMutableArray * objects = [NSMutableArray arrayWithArray:[[plugin properties] allValues]];

		for(PluginProperty * property in objects){
			[cue setChannel:0];

			NSString *searchString = [NSString stringWithFormat:@"%@: %@", [property pluginName], [property name]];
			
			NSString *beginsTest = [cue qName];
			NSRange prefixRange = [beginsTest rangeOfString:searchString options:(NSAnchoredSearch)];
			
			if(prefixRange.length > 0){
				NSLog(@"Cue match %@ %i",[cue qName], prefixRange.length);
				[cue setMidiByteOne:[[property midiChannel] intValue]];
				[cue setMidiByteTwo:[[property midiNumber] intValue]];
				//[cue set
				
			}
		}
		//	[cue setQName:@"asdasd¡¡"];
	}
}

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
	
	[addButton becomeFirstResponder];
	[panel orderFront:self];
}*/

-(void) addCue:(id)sender{
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setDecimalSeparator:@"."];
	[numberFormatter setMinimumIntegerDigits:1];
	
	
	NSString * valRep = [numberFormatter stringFromNumber:[[self linkedProperty] value]];
	NSString * name = [NSString stringWithFormat:@"[%@: %@] %@",
					   [[self linkedProperty] pluginName], 
					   [[self linkedProperty] name], 
					   [NSString stringWithFormat:@"to %@",valRep]];
	
	[self sendQlabAddCue:name channel:[linkedProperty midiChannel] control:[linkedProperty midiNumber] value:[linkedProperty midiValue] fade:NO fadeTo:0];
	
	[panel orderOut:self];
}

-(void) cancel:(id)sender{
	[panel orderOut:self];
}


-(void) sendQlabAddCue:(NSString*)name  channel:(NSNumber*)channel control:(NSNumber*)control value:(NSNumber*)value fade:(bool)fade fadeTo:(int)fadeTo{
	NSString* path = [[NSBundle mainBundle] pathForResource:@"SendToQlab" ofType:@"scpt"];
    if (path != nil)
    {
        NSURL* url = [NSURL fileURLWithPath:path];
        if (url != nil)
        {
            NSDictionary* errors = [NSDictionary dictionary];
            NSAppleScript* appleScript =
			[[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
            if (appleScript != nil)
            {
                // create the first parameter
                NSAppleEventDescriptor* firstParameter = [NSAppleEventDescriptor descriptorWithString:name];
                NSAppleEventDescriptor* secondParameter = [NSAppleEventDescriptor descriptorWithInt32:[channel intValue]];
                NSAppleEventDescriptor* thirdParameter = [NSAppleEventDescriptor descriptorWithInt32:[control intValue]];
				NSAppleEventDescriptor* fourthParameter = [NSAppleEventDescriptor descriptorWithInt32:[value intValue]];
				NSAppleEventDescriptor* fifthParameter = [NSAppleEventDescriptor descriptorWithInt32:fade];
				
                // create and populate the list of parameters (in our case just one)
                NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
                [parameters insertDescriptor:firstParameter atIndex:1];
                [parameters insertDescriptor:secondParameter atIndex:2];
				[parameters insertDescriptor:thirdParameter atIndex:3];
				[parameters insertDescriptor:fourthParameter atIndex:4];
				[parameters insertDescriptor:fifthParameter atIndex:5];
				
                // create the AppleEvent target
                ProcessSerialNumber psn = {0, kCurrentProcess};
                NSAppleEventDescriptor* target =
                [NSAppleEventDescriptor
				 descriptorWithDescriptorType:typeProcessSerialNumber
				 bytes:&psn
				 length:sizeof(ProcessSerialNumber)];
				
                // create an NSAppleEventDescriptor with the script's method name to call,
                // this is used for the script statement: "on show_message(user_message)"
                // Note that the routine name must be in lower case.
                NSAppleEventDescriptor* handler =
				[NSAppleEventDescriptor descriptorWithString:
				 [@"send_qlab" lowercaseString]];
				
                // create the event for an AppleScript subroutine,
                // set the method name and the list of parameters
                NSAppleEventDescriptor* event =
				[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
														 eventID:kASSubroutineEvent
												targetDescriptor:target
														returnID:kAutoGenerateReturnID
												   transactionID:kAnyTransactionID];
                [event setParamDescriptor:handler forKeyword:keyASSubroutineName];
                [event setParamDescriptor:parameters forKeyword:keyDirectObject];
				
                // call the event in AppleScript
                if (![appleScript executeAppleEvent:event error:&errors]);
                {
                    // report any errors from 'errors'
                }
				
                [appleScript release];
            }
            else
            {
                // report any errors from 'errors'
            }
        }
    }
}
@end
