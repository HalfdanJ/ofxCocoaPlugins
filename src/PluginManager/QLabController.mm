//
//  QLabController.mm
//  malpais
//
//  Created by Jonas Jongejan on 27/02/11.
//  Copyright 2011 HalfdanJ. All rights reserved.
//

#import "QLabController.h"

@implementation CueObject
@synthesize channel, startvalue, endvalue, fade, updateStartvalue, cue, name, duration, property, number, originalDict;


+ (NSSet*) keyPathsForValuesAffectingActualEndvalue{
	return [NSSet setWithObjects:@"startvalue", @"endvalue", @"fade", nil];
}

-(int) actualEndvalue{
	if([self fade]){
		return [self endvalue];
	} else {
		return [self startvalue];
	}
}

-(void) setActualEndvalue:(int)v{
	[self willChangeValueForKey:@"actualEndvalue"];
	if([self fade]){
		[self setEndvalue:v];
	} else {
		[self setStartvalue:v];	
	}
	[self didChangeValueForKey:@"actualEndvalue"];
}


@end


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
	
	prevCueDict = [[CueObject alloc] init];
	[prevCueDict setCue:prevCue];

	thisCueDict = [[CueObject alloc] init];
	[thisCueDict setCue:thisCue];

	nextCueDict = [[CueObject alloc] init];
	[nextCueDict setCue:nextCue];

	
	[self populateCueDict:prevCueDict];
	[self setShownPrevCueDict:prevCueDict];


	[self populateCueDict:thisCueDict];
	[self setShownThisCueDict:thisCueDict];

	[self populateCueDict:nextCueDict];	
	[self setShownNextCueDict:nextCueDict];

	[self addObserver:self forKeyPath:@"shownThisCueDict.actualEndvalue" options:nil context:@"endvalue"];
	[self addObserver:self forKeyPath:@"shownNextCueDict.updateStartvalue" options:nil context:@"endvalue"];
	
	[[self shownThisCueDict] setActualEndvalue:[[linkedProperty midiValue] intValue]];
	
	if(!makeNewCue){
		[updateCheck setHidden:NO];
	} else {
		[updateCheck setHidden:YES];
	}
	//[self updateGui];
	
	[panel orderFront:self];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([context isEqualToString:@"endvalue"]){
		if([[self shownNextCueDict] cue] && [[self shownNextCueDict] fade] && [[self shownNextCueDict] updateStartvalue]){
			[[self shownNextCueDict] setStartvalue:[[self shownThisCueDict] actualEndvalue]];
		} else if([[self shownNextCueDict] cue]){
			[[self shownNextCueDict] setStartvalue:[[[[self shownNextCueDict] originalDict] valueForKey:@"startvalue"] intValue]];
		}
	}
}


-(void) populateCueDict:(CueObject*)obj{
	QLabCue * cue = [obj cue];
	
	if(cue){
		[obj setName:[cue qName]];
		
		NSDictionary * info = [self getCueInfo:cue];
		[obj setChannel:[[info valueForKey:@"channel"] intValue]];
		[obj setDuration:[info valueForKey:@"duration"]];
		[obj setEndvalue:[[info valueForKey:@"endvalue"]intValue] ];
		[obj setFade:[[info valueForKey:@"fade"] boolValue]];
		[obj setNumber:[[info valueForKey:@"number"] intValue]];
		[obj setStartvalue:[[info valueForKey:@"startvalue"] intValue]];
		[obj setOriginalDict:info];
		/*
		if([[info valueForKey:@"fade"] intValue] == 1 && dict == nextCueDict){
			[dict setObject:[NSNumber numberWithInt:1] forKey:@"updateStartvalue"];
			[dict setObject:[shownThisCueDict valueForKey:@"endvalue"] forKey:@"startvalue"];
		}
		else {
			[dict setObject:[NSNumber numberWithInt:0] forKey:@"updateStartvalue"];
		}*/
	} else {
		[obj setName:@"-" ];
	}
		
}

-(NSMutableDictionary*) newCue{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setObject:@"New cue" forKey:@"name"];
	[dict setObject:[linkedProperty midiChannel] forKey:@"channel"];
	[dict setObject:[NSNumber numberWithInt:5] forKey:@"duration"];
	[dict setObject:[linkedProperty midiValue] forKey:@"endvalue"];
	[dict setObject:[NSNumber numberWithInt:1] forKey:@"fade"];
	[dict setObject:[linkedProperty midiNumber] forKey:@"number"];
	
	[dict setObject:[NSNumber numberWithInt:0] forKey:@"startvalue"];
	
	
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
		
		if([shownPrevCueDict valueForKey:@"cue"] && [[shownPrevCueDict valueForKey:@"fade"] intValue] == 1){
			[[self shownThisCueDict] setValue:[shownPrevCueDict valueForKey:@"endvalue"] forKey:@"startvalue"];
		} else if([shownPrevCueDict valueForKey:@"cue"] && [[shownPrevCueDict valueForKey:@"fade"] intValue] == 0){
			[[self shownThisCueDict] setValue:[shownPrevCueDict valueForKey:@"startvalue"] forKey:@"startvalue"];			
		}
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



-(NSDictionary*) getCueInfo:(QLabCue*)cue{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
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
                NSAppleEventDescriptor* firstParameter = [NSAppleEventDescriptor descriptorWithString:[cue uniqueID]];
                NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
                [parameters insertDescriptor:firstParameter atIndex:1];
				
                // create the AppleEvent target
                ProcessSerialNumber psn = {0, kCurrentProcess};
                NSAppleEventDescriptor* target =
                [NSAppleEventDescriptor
				 descriptorWithDescriptorType:typeProcessSerialNumber
				 bytes:&psn
				 length:sizeof(ProcessSerialNumber)];
				
                NSAppleEventDescriptor* handler =
				[NSAppleEventDescriptor descriptorWithString:
				 [@"get_cue_info" lowercaseString]];
				
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
				NSAppleEventDescriptor* retDesc = [appleScript executeAppleEvent:event error:&errors];
                if (retDesc);
                {
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:1] int32Value]] forKey:@"channel"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:2] int32Value]] forKey:@"number"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:3] int32Value]] forKey:@"startvalue"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:4] int32Value]] forKey:@"endvalue"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:5] int32Value]] forKey:@"fade"];
					[dict setValue:[[retDesc descriptorAtIndex:6] stringValue] forKey:@"duration"];

					NSLog(@"%@",dict);
				}
				
				


                [appleScript release];
            }
            else
            {
                // report any errors from 'errors'
            }
        }
    }
	
	return dict;	
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
