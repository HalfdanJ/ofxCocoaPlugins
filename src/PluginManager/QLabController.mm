//
//  QLabController.mm
//  malpais
//
//  Created by Jonas Jongejan on 27/02/11.
//  Copyright 2011 HalfdanJ. All rights reserved.
//

#import "QLabController.h"


@implementation QLabController
@synthesize linkedProperty, shownPrevCueDict, shownNextCueDict, shownThisCueDict;


-(id) init{
	if([super init]){

		
	}
	return self;
}

-(QLabApplication*) getQLab{
	return [[SBApplication applicationWithBundleIdentifier:@"com.figure53.Qlab.2"] retain];
}

-(void) updateQlabForPlugin:(ofPlugin*) plugin{
	QLabApplication *qLab = [self getQLab]; 
	NSArray *workspaces = [qLab workspaces];
	QLabWorkspace * workspace = [workspaces objectAtIndex:0];
	
	NSMutableArray * objects = [NSMutableArray arrayWithArray:[[plugin properties] allValues]];
	for(PluginProperty * proptery in objects){
		
		for(QLabCue * cue in [workspace cues]){
			NSString *searchString = [NSString stringWithFormat:@"%@: %@", [proptery pluginName], [proptery name]];
			
			NSString *beginsTest = [cue qName];
			NSRange prefixRange = [beginsTest rangeOfString:searchString options:(NSAnchoredSearch)];
			
			if(prefixRange.length > 0){
				NSLog(@"Cue %@ %i",[cue qName], prefixRange.length);

				[self setMidiChannel:[[proptery midiChannel] intValue] number:[[proptery midiNumber] intValue] forCue:cue];
				//[cue set
				
			}
			//	[cue setQName:@"asdasd¡¡"];
		}
	}
	
}

-(void) startQlabTransaction:(PluginProperty*)proptery{
	thisCue = nil;
	prevCue = nil;
	nextCue = nil;
	
	[updateCheck setState:1];
	
	BOOL makeNewCue = NO;	
	multipleSelection = NO;
	
	[self setLinkedProperty:proptery];
	
	QLabApplication *qLab = [SBApplication applicationWithBundleIdentifier:@"com.figure53.Qlab.2"]; 
	NSArray *workspaces = [qLab workspaces];
	QLabWorkspace * workspace = [workspaces objectAtIndex:0];
	
	
	//Search string
	NSString *searchString = [NSString stringWithFormat:@"%@: %@", [proptery pluginName], [proptery name]];		
	
	
	NSMutableArray * propertyCues = [NSMutableArray array];	

	
	//Først finder vi ud af hvad vi har markeret
	NSMutableArray * selectedCues = [NSMutableArray arrayWithArray:[workspace selected]];
	NSMutableArray * selectedPropertyCues = [NSMutableArray array];
	
	for(int i=0;i<[selectedCues count];i++){
		for(QLabCue * subCue in [[selectedCues objectAtIndex:i] cues]){
			if(![selectedCues containsObject:subCue])
				[selectedCues addObject:subCue];
		}
	}
	
	//Er der en eller flere af dem der er denne property?
	for(QLabCue * cue in selectedCues){
		NSString *beginsTest = [cue qName];
		NSRange prefixRange = [beginsTest rangeOfString:searchString options:(NSAnchoredSearch)];
		
		if(prefixRange.length > 0){
			[selectedPropertyCues addObject:cue];
		}		
	}
		
	//Hvis der bare er en property cue, så er det selectedPropertyCue
	if([selectedPropertyCues count] == 1){
		multipleSelection = NO;
	} 
	//Hvis der er flere
	if([selectedPropertyCues count] > 1){
		multipleSelection = YES;	
	}
	//Hvis der ikke er nogen
	if([selectedPropertyCues count] == 0){
		makeNewCue = YES;
	}
	
	
	NSLog(@"Make new cue: %i	multiple selection: %i   Number selection: %i",makeNewCue,multipleSelection,[selectedCues count]);
	
	
	//Nu går vi igennem alle cues, og populater propertyCues, og ser om vi kan udfylde this, next og prev
	BOOL indexFound = NO;
	for(QLabCue * cue in [workspace cues]){
		NSLog(@"%@:",[cue qName]);
		
		NSString *beginsTest = [cue qName];
		NSRange prefixRange = [beginsTest rangeOfString:searchString options:(NSAnchoredSearch)];		
		if(prefixRange.length > 0){
			//Det er en property cue
			[propertyCues addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cue qName],@"name",nil]];
			

			if(!makeNewCue && [[[selectedPropertyCues objectAtIndex:0] uniqueID] isEqualToString:[cue uniqueID]]){
				indexFound = YES;
			}	
			if([[[selectedPropertyCues lastObject] uniqueID] isEqualToString:[cue uniqueID]]){
				thisCue = cue;
				if(prevCue == cue){
					prevCue = nil;
				}
				
			} else if((thisCue || (makeNewCue && indexFound)) && !nextCue){
				nextCue = cue;
			}
			
			if(!indexFound){
				prevCue = cue;
			}
			
			
			
		} else {
			//Det er ikke nogen property cue
			if(makeNewCue){
				if([[[selectedCues lastObject] uniqueID] isEqualToString:[cue uniqueID]]){
					indexFound = YES;
				}
			} else {
					
			}
		}		
	}
	
	prevCueDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:prevCue,@"cue",nil];		
	thisCueDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:thisCue,@"cue",nil];		
	nextCueDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:nextCue,@"cue",nil];		
	
	[self populateCueDict:prevCueDict];
	[self populateCueDict:nextCueDict];
	[self populateCueDict:thisCueDict];
	
	[self setShownPrevCueDict:prevCueDict];
	[self setShownThisCueDict:thisCueDict];
	[self setShownNextCueDict:nextCueDict];
	
	
	if(!makeNewCue){
		[updateCheck setHidden:NO];
	} else {
		[updateCheck setHidden:YES];
	}
	//[self updateGui];
	
	[panel orderFront:self];
}

-(void) populateCueDict:(NSMutableDictionary*)dict{
	QLabCue * cue = [dict valueForKey:@"cue"];
	
	if(cue){
		[dict setObject:[cue qName] forKey:@"name"];
	} else {
		[dict setObject:@"-" forKey:@"name"];
	}
}

-(NSMutableDictionary*) newCue{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setObject:@"New cue" forKey:@"name"];
	
	return dict;
}

-(IBAction) setUpdateChecked:(id)sender{
	if([sender state]){
		[self setShownPrevCueDict:prevCueDict];
		[self setShownThisCueDict:thisCueDict];
		[self setShownNextCueDict:nextCueDict];		
	} else {
		[self setShownPrevCueDict:thisCueDict];
		[self setShownThisCueDict:[self newCue]];
		[self setShownNextCueDict:nextCueDict];				
	}
}


/*
-(void) updateGui{

	if(!makeNewCue){
		[updateCheck setHidden:NO];
	} else {
		[updateCheck setHidden:YES];
	}

	
	if(makeNewCue){
		[thisName setStringValue:@"New Cue"];	
	}
	else if(multipleSelection){
		[thisName setStringValue:@"Multiple"];	
	} else if(thisCue != nil){
		[thisName setStringValue:[thisCue qName]];
	} else {
		[thisName setStringValue:@"-"];	
	}
	
	if(nextCue != nil){
		[nextName setStringValue:[nextCue qName]];
	} else {
		[nextName setStringValue:@"-"];	
	}
	
	if(prevCue != nil){
		[prevName setStringValue:[prevCue qName]];
	} else {
		[prevName setStringValue:@"-"];	
	}
	
	
}*/
-(NSDictionary*) getThisCueDict{
	
}
-(NSDictionary*) getNextCueDict{
	
}
-(NSDictionary*) getPrevCueDict{
	
}


-(void) setMidiChannel:(int)channel number:(int)number forCue:(QLabCue*)cue{
	NSLog(@"Set midi channel %i number %i for %@ %@",channel,number, [cue qName], [cue uniqueID]);
	
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
                NSAppleEventDescriptor* firstParameter = [NSAppleEventDescriptor descriptorWithString:[cue uniqueID]];
                NSAppleEventDescriptor* secondParameter = [NSAppleEventDescriptor descriptorWithInt32:channel];
                NSAppleEventDescriptor* thirdParameter = [NSAppleEventDescriptor descriptorWithInt32:number];
				
                // create and populate the list of parameters (in our case just one)
                NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
                [parameters insertDescriptor:firstParameter atIndex:1];
                [parameters insertDescriptor:secondParameter atIndex:2];
				[parameters insertDescriptor:thirdParameter atIndex:3];
				
                // create the AppleEvent target
                ProcessSerialNumber psn = {0, kCurrentProcess};
                NSAppleEventDescriptor* target =
                [NSAppleEventDescriptor
				 descriptorWithDescriptorType:typeProcessSerialNumber
				 bytes:&psn
				 length:sizeof(ProcessSerialNumber)];
				
                NSAppleEventDescriptor* handler =
				[NSAppleEventDescriptor descriptorWithString:
				 [@"set_midi" lowercaseString]];
				
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
