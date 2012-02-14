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

+(NSSet*) keyPathsForValuesAffectingUndefinedCue{
	return [NSSet setWithObjects:@"cue",nil];
}

-(BOOL) undefinedCue{
	if(cue)
		return NO;
	else {
		return YES;
	}
	
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

-(int) originalActualEndvalue{
	if([[[self originalDict] objectForKey:@"fade"] boolValue]){
		return [[[self originalDict] valueForKey:@"endvalue"] intValue];
	} else {
		return [[[self originalDict] valueForKey:@"startvalue"] intValue];
	}
}

-(void) restoreStartvalue{
	if([self originalDict]){
		[self setStartvalue:[[[self originalDict] valueForKey:@"startvalue"] intValue]];	
	}
}
-(void) restoreEndvalue{
	if([self originalDict]){
		[self setEndvalue:[[[self originalDict] valueForKey:@"endvalue"] intValue]];
	}
}

-(void) updateName{
	NSMutableString * str = [NSMutableString stringWithFormat:@"[%@: %@] ", [property pluginName], [property name]];
	if([self fade]){
		[self setName:[NSString stringWithFormat:@"%@ %i to %i (fading)", str, [self startvalue], [self endvalue]]];
	} else {
		[self setName:[NSString stringWithFormat:@"%@ to %i", str, [self startvalue]]];		
	}
	
}


@end


@implementation QLabController
@synthesize linkedProperty, shownPrevCueDict, shownNextCueDict, shownThisCueDict;


-(id) init{
	if(self = [super init]){
		[self addObserver:self forKeyPath:@"shownThisCueDict.actualEndvalue" options:nil context:@"endvalue"];
		[self addObserver:self forKeyPath:@"shownThisCueDict.fade" options:nil context:@"fade"];
		[self addObserver:self forKeyPath:@"shownNextCueDict.updateStartvalue" options:nil context:@"endvalue"];
		
		thread = [[NSThread alloc] initWithTarget:self selector:@selector(blinkName) object:nil];
        //	[thread start];
	}
	return self;
}

-(void) awakeFromNib{
}

-(QLabApplication*) getQLab{
	return [[SBApplication applicationWithBundleIdentifier:@"com.figure53.Qlab.2"] retain];
}

-(void) updateQlabForPlugin:(ofPlugin*) plugin{
	QLabApplication *qLab = [self getQLab]; 
	NSArray *workspaces = [qLab workspaces];
	QLabWorkspace * workspace = [workspaces objectAtIndex:0];
	
	NSMutableArray * objects = [NSMutableArray arrayWithArray:[[plugin properties] allValues]];
	for(QLabCue * cue in [workspace cues]){
		//NSLog(@"CUe");
		NSString *beginsTest = [cue qName];
		for(PluginProperty * proptery in objects){		
			NSString *searchString = [NSString stringWithFormat:@"[%@: %@]", [proptery pluginName], [proptery name]];		
			int length = [beginsTest length];
			NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];
			
			if(prefixRange.length > 0){
				NSLog(@"Cue %@ prefix length: %u  searchstring length: %i",[cue qName], prefixRange.length, length);
				
				[self setMidiChannel:[[proptery midiChannel] intValue] number:[[proptery midiNumber] intValue] forCue:cue];
				//[cue set
				
			}
			//	[cue setQName:@"asdasd¡¡"];
		}
	}
	
}

-(void) startQlabTransaction:(PluginProperty *)proptery fadingAllowed:(BOOL)_fadeAllowed verbose:(BOOL)_verbose{    
	verbose = _verbose;
	fadeAllowed = _fadeAllowed;
    
    
        
	
	thisCue = nil;
	prevCue = nil;
	nextCue = nil;
	
	[updateCheck setState:1];
	
	BOOL makeNewCue = NO;	
	multipleSelection = NO;
	
	[self setLinkedProperty:proptery];
    
    if(!verbose){

        [self setShownThisCueDict:[self newCue]];
        if([linkedProperty midiNumber] && [linkedProperty midiChannel])
			[self go:self];
        return;
    }
	
	QLabApplication *qLab = [SBApplication applicationWithBundleIdentifier:@"com.figure53.Qlab.2"]; 
	NSArray *workspaces = [qLab workspaces];
	QLabWorkspace * workspace = [workspaces objectAtIndex:0];
	
	
	//Search string
	NSString *searchString = [NSString stringWithFormat:@"[%@: %@]", [proptery pluginName], [proptery name]];		
	
	
	NSMutableArray * propertyCues = [NSMutableArray array];	
	
	
	//Først finder vi ud af hvad vi har markeret
	NSMutableArray * selectedCues = [NSMutableArray arrayWithArray:[workspace selected]];
	NSMutableArray * selectedPropertyCues = [NSMutableArray array];
	
        for(int i=0;i<[selectedCues count];i++){
            QLabCue * cue = [selectedCues objectAtIndex:i];
            NSString *beginsTest = [cue qName];
            NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];
            
            if(prefixRange.length > 0){
                [selectedPropertyCues addObject:cue];
                break;
            }		
            
            for(QLabCue * subCue in [[selectedCues objectAtIndex:i] cues]){
                if(![selectedCues containsObject:subCue])
                    [selectedCues addObject:subCue];
            }
        }
	
	//Er der en eller flere af dem der er denne property?
	/*for(QLabCue * cue in selectedCues){
		NSString *beginsTest = [cue qName];
		NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];
		
		if(prefixRange.length > 0){
			[selectedPropertyCues addObject:cue];
		}		
	}*/
	
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
	
	
	NSLog(@"Make new cue: %i	multiple selection: %i   Number selection: %u",makeNewCue,multipleSelection,[selectedCues count]);
	
	
	//Nu går vi igennem alle cues, og populater propertyCues, og ser om vi kan udfylde this, next og prev
	BOOL indexFound = NO;
	for(QLabCue * cue in [workspace cues]){
		NSString * cueName = [[cue qName] copy];
		NSLog(@"%@:",cueName);
		
		NSString *beginsTest = cueName;
		NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];		
		NSLog(@"Search length: %u for cue %@", prefixRange.length, cueName);
		
		if(prefixRange.length > 0){
			//Det er en property cue
			[propertyCues addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cue qName],@"name",nil]];
			
			
			if(!makeNewCue && [[((QLabCue*)[selectedPropertyCues objectAtIndex:0]) uniqueID] isEqualToString:[cue uniqueID]]){
				indexFound = YES;
			}	
			if([[((QLabCue*)[selectedPropertyCues lastObject]) uniqueID] isEqualToString:[cue uniqueID]]){
				thisCue = cue;
				if(prevCue == cue){
					prevCue = nil;
				}
				
			} else if((thisCue || (makeNewCue   && indexFound)) && !nextCue){
				nextCue = cue;
                break;
			}
			
			if(!indexFound){
				prevCue = cue;
			}
			
			
			
		} else {
			//Det er ikke nogen property cue
			if(makeNewCue){
				if([[((QLabCue*)[selectedCues lastObject]) uniqueID] isEqualToString:[cue uniqueID]]){
					indexFound = YES;
				}
			}
		}		
	}
	
	prevCueDict = [[CueObject alloc] init];
	[prevCueDict setCue:prevCue];
	
	if(thisCue){
		thisCueDict = [[CueObject alloc] init];
		[thisCueDict setCue:thisCue];
	} else {
		thisCueDict = [self newCue];
	}
	
	nextCueDict = [[CueObject alloc] init];
	[nextCueDict setCue:nextCue];
	
	
	[self populateCueDict:prevCueDict];
	[self setShownPrevCueDict:prevCueDict];
	
	if(thisCue){
		[self populateCueDict:thisCueDict];
	}
	[self setShownThisCueDict:thisCueDict];
	
	[self populateCueDict:nextCueDict];	
	[self setShownNextCueDict:nextCueDict];
	
	
	
	[okButton setTitle:@"Update"];
	if(!makeNewCue){
		[updateCheck setHidden:NO];
	} else {
		[updateCheck setHidden:YES];
		[updateCheck setState:0];
		[okButton setTitle:@"Add"];
	}
	
	
	if([[self shownThisCueDict] cue]){
		//Vi er i update mode	
		NSLog(@"Actual end value: %i == %i",[[self shownThisCueDict] originalActualEndvalue],[[self shownNextCueDict] startvalue]);
		if([[self shownNextCueDict] fade] && [[self shownThisCueDict] originalActualEndvalue] == [[self shownNextCueDict] startvalue]){
			[[self shownNextCueDict] setUpdateStartvalue:YES];
		}
	} else {
		//Vi er i ny cue mode
		if([[self shownNextCueDict] fade] && [[self shownPrevCueDict] actualEndvalue] == [[self shownNextCueDict] startvalue]){
			[[self shownNextCueDict] setUpdateStartvalue:YES];
		}
	}
	
	[[self shownThisCueDict] setActualEndvalue:[[linkedProperty midiValue] intValue]];
	
	
	if(verbose){
        //	blinkRunning = YES;
		[panel makeKeyAndOrderFront:self];
	} else {
		if([linkedProperty midiNumber] && [linkedProperty midiChannel])
			[self go:self];
	}
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([((NSString*)context) isEqualToString:@"endvalue"]){
		if([[self shownNextCueDict] cue] && [[self shownNextCueDict] fade] && [[self shownNextCueDict] updateStartvalue]){
			[[self shownNextCueDict] setStartvalue:[[self shownThisCueDict] actualEndvalue]];
		} else if([[self shownNextCueDict] cue]){
			[[self shownNextCueDict] setStartvalue:[[[[self shownNextCueDict] originalDict] valueForKey:@"startvalue"] intValue]];
		}
	}
	if([((NSString*)context) isEqualToString:@"fade"]){
		if([[self shownThisCueDict] fade]){
			[[self shownThisCueDict] setStartvalue:[[self shownPrevCueDict] actualEndvalue]];	
			[[self shownThisCueDict] setEndvalue:[[linkedProperty midiValue] intValue]];			
		} else {
			[[self shownThisCueDict] setStartvalue:[[linkedProperty midiValue] intValue]];	
		}
	}
}


-(void) populateCueDict:(CueObject*)obj{
	QLabCue * cue = [obj cue];
	[obj setProperty:linkedProperty];
	
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
	} else {
		[obj setName:@"-" ];
	}
	
}

-(CueObject*) newCue{
	CueObject * obj = [[CueObject alloc] init];
	
	[obj setName:@"New cue"];
	[obj setChannel:[[linkedProperty midiChannel] intValue]];
	[obj setDuration:[NSNumber numberWithInt:5]];
	[obj setEndvalue:[[linkedProperty midiValue] intValue] ];
	[obj setFade:fadeAllowed];
	[obj setNumber:[[linkedProperty midiNumber] intValue]];
	[obj setStartvalue:[[self shownPrevCueDict] actualEndvalue]];
	[obj setProperty:linkedProperty];
	
	return obj;
}

-(IBAction) setUpdateChecked:(id)sender{
	if([sender state]){
		//Update current cue
		[self setShownPrevCueDict:prevCueDict];
		[self setShownThisCueDict:thisCueDict];
		[self setShownNextCueDict:nextCueDict];	
		
		[[self shownThisCueDict] setActualEndvalue:[[linkedProperty midiValue] intValue]];
		
		[okButton setTitle:@"Update"];
	} else {
		//Make new cue
		[self setShownPrevCueDict:thisCueDict];
		[[self shownPrevCueDict] restoreEndvalue];
		[[self shownPrevCueDict] restoreStartvalue];
		
		[self setShownThisCueDict:[self newCue]];
		[self setShownNextCueDict:nextCueDict];		
		
		if([shownPrevCueDict valueForKey:@"cue"] && [[shownPrevCueDict valueForKey:@"fade"] intValue] == 1){
			[[self shownThisCueDict] setValue:[shownPrevCueDict valueForKey:@"endvalue"] forKey:@"startvalue"];
		} else if([shownPrevCueDict valueForKey:@"cue"] && [[shownPrevCueDict valueForKey:@"fade"] intValue] == 0){
			[[self shownThisCueDict] setValue:[shownPrevCueDict valueForKey:@"startvalue"] forKey:@"startvalue"];			
		}
		
		[okButton setTitle:@"Add"];
	}
}

-(IBAction) go:(id)sender{
	
	if([[self shownNextCueDict] cue]){
		if([[self shownNextCueDict] updateStartvalue]){	
			[[self shownNextCueDict] updateName];
			[self updateCue:[self shownNextCueDict]];
		}
		//	[self updateCue:[self shownThisCueDict]];
	}
	
	[[self shownThisCueDict] updateName];
	[self updateCue:[self shownThisCueDict]];
	
	
	[panel orderOut:self];
	[self stopBlink];
}


-(IBAction) cancel:(id)sender{
	[self stopBlink];	
	[panel orderOut:self];
}


-(void) stopBlink{
	blinkRunning = NO;	
}

-(void) blinkName{
	NSString *searchString = @"<--";
	
	
	while(1){
		if(blinkRunning || blink){
			NSLog(@"Blink %i", blink);
			if(thisCue){
				NSString *beginsTest = [thisCue qName];
				NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];						
				
				if(!blink && prefixRange.length == 0)
					[thisCue setQName:[NSString stringWithFormat:@"%@ <--",[thisCue qName]]];
				else if(prefixRange.length > 0){
					NSString * str = [thisCue qName];
					int length = [str length];
					[thisCue setQName:[str substringToIndex:length-4]];
				}					
			}
			
			if(prevCue){
				NSString *beginsTest = [prevCue qName];
				NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];		
				
				if(!blink && prefixRange.length == 0 && prevCue == [[self shownPrevCueDict] cue])
					[prevCue setQName:[NSString stringWithFormat:@"%@ <--",[prevCue qName]]];
				else if(prefixRange.length > 0){
					NSString * str = [prevCue qName];
					int length = [str length];
					[prevCue setQName:[str substringToIndex:length-4]];
				}					
			}
			if(nextCue){
				NSString *beginsTest = [nextCue qName];
				NSRange prefixRange = [beginsTest rangeOfString:searchString options:(0)];						
				
				if(!blink && prefixRange.length == 0)
					[nextCue setQName:[NSString stringWithFormat:@"%@ <--",[nextCue qName]]];
				else if(prefixRange.length > 0){
					NSString * str = [nextCue qName];
					int length = [str length];
					[nextCue setQName:[str substringToIndex:length-4]];
				}					
			}
			
			
			
			blink = !blink;
		}
		
		[NSThread sleepForTimeInterval:1];
	}
}

-(NSDictionary*) getCueInfo:(QLabCue*)cue{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SendToQlab" ofType:@"scpt"];
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
				[NSAppleEventDescriptor descriptorWithString:[@"get_cue_info" lowercaseString]];
				
				NSAppleEventDescriptor* event =	[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
																						 eventID:kASSubroutineEvent
																				targetDescriptor:target
																						returnID:kAutoGenerateReturnID
																				   transactionID:kAnyTransactionID];
				[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
				[event setParamDescriptor:parameters forKeyword:keyDirectObject];
				
				// call the event in AppleScript
				NSAppleEventDescriptor* retDesc = [appleScript executeAppleEvent:event error:&errors];
				if (retDesc)
				{
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:1] int32Value]] forKey:@"channel"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:2] int32Value]] forKey:@"number"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:3] int32Value]] forKey:@"startvalue"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:4] int32Value]] forKey:@"endvalue"];
					[dict setValue:[NSNumber numberWithInt:[[retDesc descriptorAtIndex:5] int32Value]] forKey:@"fade"];
					[dict setValue:[[retDesc descriptorAtIndex:6] stringValue] forKey:@"duration"];
				}
				
				[appleScript release];
			}
		}
	}
	
	return dict;	
}


-(void) setMidiChannel:(int)channel number:(int)number forCue:(QLabCue*)cue{
	NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SendToQlab" ofType:@"scpt"];
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
				if (![appleScript executeAppleEvent:event error:&errors])
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


-(void) updateCue:(CueObject*)cue{	
	NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SendToQlab" ofType:@"scpt"];
	if (path != nil)
	{
		NSURL* url = [NSURL fileURLWithPath:path];
		if (url != nil)
		{
			NSDictionary* errors = [NSDictionary dictionary];
			NSAppleScript* appleScript =
			[[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
			if (appleScript != nil){
				
				if([cue cue]){								
					// create and populate the list of parameters
					NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[[cue cue] uniqueID]] atIndex:1];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue channel]] atIndex:2];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue number]] atIndex:3];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[cue  name]] atIndex:4];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue startvalue]] atIndex:5];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue endvalue]] atIndex:6];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue fade]] atIndex:7];
					
					[[cue cue] setDuration:[[cue duration] doubleValue]];
					
					// create the AppleEvent target
					ProcessSerialNumber psn = {0, kCurrentProcess};
					NSAppleEventDescriptor* target =
					[NSAppleEventDescriptor
					 descriptorWithDescriptorType:typeProcessSerialNumber
					 bytes:&psn
					 length:sizeof(ProcessSerialNumber)];
					
					NSAppleEventDescriptor* handler =
					[NSAppleEventDescriptor descriptorWithString:
					 [@"update_cue" lowercaseString]];
					
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
					if (![appleScript executeAppleEvent:event error:&errors])
					{
						NSLog(@"Error updating cue.. Damn! %@",errors);
					}
					
					[appleScript release];
					
					
				} else {
					// create and populate the list of parameters
					NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue channel]] atIndex:1];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue number]] atIndex:2];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[cue  name]] atIndex:3];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue startvalue]] atIndex:4];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue endvalue]] atIndex:5];
					[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[cue fade]] atIndex:6];
					
					//				[[cue cue] setDuration:[[cue duration] doubleValue]];
					
					// create the AppleEvent target
					ProcessSerialNumber psn = {0, kCurrentProcess};
					NSAppleEventDescriptor* target =
					[NSAppleEventDescriptor
					 descriptorWithDescriptorType:typeProcessSerialNumber
					 bytes:&psn
					 length:sizeof(ProcessSerialNumber)];
					
					NSAppleEventDescriptor* handler =
					[NSAppleEventDescriptor descriptorWithString:
					 [@"add_cue" lowercaseString]];
					
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
					if (![appleScript executeAppleEvent:event error:&errors])
					{
						NSLog(@"Error updating cue.. Damn! %@",errors);
					}
					
					[appleScript release];
					
					
				}
			}
		}
	}
	
	
}


@end
