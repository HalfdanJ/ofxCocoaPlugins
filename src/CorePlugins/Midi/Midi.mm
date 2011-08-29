/*
 *  Midi.cpp
 *  openFrameworks
 *
 *  Created by ole kristensen on 11/01/10.
 *  Copyright 2010 Recoil Performance Group. All rights reserved.
 *
 */

#include "Midi.h"
#include "PYMIDI.h"

@implementation Midi
@synthesize boundControls, midiBindings, midiData, mtcTimeString;

-(id) init{
	if([super init]){
		//pthread_mutex_init(&mutex, NULL);
		
		showMidiConflictAlert = false;
		didShowMidiConflictAlert = false;
		
		userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		
		manager = [PYMIDIManager sharedInstance];
		endpoint = (PYMIDIVirtualSource*)[[PYMIDIRealEndpoint alloc] init];
		//endpoint = [[PYMIDIVirtualEndpoint alloc] initWithName:@"Malpais MIDI"];
		
		[endpoint retain];
		[endpoint addReceiver:self];
		
		sendEndpoint = (PYMIDIVirtualDestination*) new PYMIDIRealEndpoint;
		//	[sendEndpoint retain];
		
		NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
		virtualDestination = [[PYMIDIVirtualDestination alloc] initWithName:[appName stringByAppendingString:@" Virtual MIDI"]];
		
		[virtualDestination retain];
		[virtualDestination makePrivate:NO];
		[virtualDestination addReceiver:self];
		
		updateView = false;
		
		boundControls = [[[NSMutableArray alloc] initWithCapacity:2] retain];
		
		//[self setBoundControls:[boundControlsController content]]; //
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midiSetupChanged) name:@"PYMIDISetupChanged" object:nil];
		
		
		midiBindings = [[NSMutableArray array] retain];
		midiData = [[NSMutableArray array] retain];
		
		for(int i=0; i<17; i++){
			
			NSMutableDictionary * aChannel = [NSMutableDictionary dictionary];
			
			for (int j=0; j<128; j++) {
				[aChannel setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%i", j]];
			}
			
			[midiData addObject:aChannel]; 
			
		}
		
		for(int i=0;i<16;i++){
			pitchBends[i] = 0;
		}
	}
	return self;
}

-(BOOL) autoresizeControlview{
	return YES;
}

-(void) initPlugin{
	//dispatch_async(dispatch_get_main_queue(), ^{
	
	//});
	
}

-(void) setup{
	[self buildMidiInterfacePopUp];
	
	[midiMappingsList setDoubleAction:@selector(showSelectedControl:)];
	
	
}

- (IBAction)showSelectedControl:(id)sender {
	
	
	NSInteger theRow = [boundControlsController selectionIndex];
	
    if ( theRow != NSNotFound ) { 
		
        /*PluginUIMidiBinding* selectedBinding =
		 (PluginUIMidiBinding*) [[boundControlsController arrangedObjects]
		 objectAtIndex: theRow];
		 */
		//        [selectedBinding bringIntoView];
		
    }
	
}

-(void) showConflictSheet{
	if(!didShowMidiConflictAlert){
		
		NSBeginCriticalAlertSheet(NSLocalizedString(@"MIDI Controller Conflict", @"Title of alert panel which comes up when user chooses Quit"),
								  NSLocalizedString(@"Continue", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
								  NSLocalizedString(@"Quit", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),
								  NSLocalizedString(@"Show conflicts", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),
								  [NSApp mainWindow],
								  self,
								  @selector(willEndCloseConflictSheet:returnCode:contextInfo:),
								  @selector(didEndCloseConflictSheet:returnCode:contextInfo:),
								  nil,
								  NSLocalizedString(@"Some of the midi controllers are conflicting, they are highlighted in red in the list of midiControllers.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents.")
								  );
		didShowMidiConflictAlert = true;
	}
	
}

- (void)willEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {       /* "Continue" */
		// do nothing
	} 
	if (returnCode == NSAlertAlternateReturn) {     /* "Quit" */
		[(PluginManagerController*)[[NSApplication sharedApplication] delegate] setQuitWithoutAsking:YES];
		[[NSApplication sharedApplication] terminate:self];
	}
	
	if (returnCode == NSAlertOtherReturn) {			/* "Show conflicts" */
        //		[globalController changeView:[[globalController viewItems] indexOfObject:self]];
	}       
}

- (void)didEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {       /* "Continue" */
		// do nothing
	} 
	if (returnCode == NSAlertAlternateReturn) {     /* "Quit" */
		[(PluginManagerController*)[[NSApplication sharedApplication] delegate] setQuitWithoutAsking:YES];
		[[NSApplication sharedApplication] terminate:self];
	}
	
	if (returnCode == NSAlertOtherReturn) {			/* "Show conflicts" */
        //	[globalController changeView:[[globalController viewItems] indexOfObject:self]];
	}       
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	updateTimeInterval = timeInterval;
	
	//	NSMutableIndexSet * rowIndexesChanged = [[NSMutableIndexSet alloc] init];
	
	//	id theBinding;
	//	int rowIndex = 0;
	
	/*pthread_mutex_lock(&mutex);
	 
	 for (theBinding in boundControls){
	 [theBinding update:timeInterval displayTime:outputTime];
	 if([theBinding hasChanged] || [theBinding activity]){
	 NSInteger row = [[boundControlsController arrangedObjects] indexOfObject:theBinding];
	 if (row != NSNotFound) {
	 [rowIndexesChanged addIndex:row];
	 }			
	 }
	 rowIndex++;
	 }
	 
	 [self performSelectorOnMainThread:@selector(_reloadRows:) withObject:rowIndexesChanged waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];	
	 
	 pthread_mutex_unlock(&mutex);*/
	
	//	if(timeInterval - midiTimeInterval > 0.15) {
	//		[[[globalController controlPanel] midiStatus] setState:NSOffState];
	//	}
	
	//	[rowIndexesChanged release];
}

-(MTCTime)getMTCTime{
    return mtcTime;
}

-(float)getMTCSeconds{
    return mtcTime.hours*60*60 + mtcTime.minutes*60 + mtcTime.seconds + (mtcTime.frames / (float)mtcTime.fps);
}   

BOOL isDataByte (Byte b)		{ return b < 0x80; }
BOOL isStatusByte (Byte b)		{ return b >= 0x80 && b < 0xF8; }
BOOL isRealtimeByte (Byte b)	{ return b >= 0xF8; }

- (void)processMIDIPacketList:(MIDIPacketList*)packetList sender:(id)sender {
	//	midiTimeInterval = updateTimeInterval;
	
	//	NSMutableIndexSet * rowIndexesChanged = [[NSMutableIndexSet alloc] init];
	
	MIDIPacket * packet = &packetList->packet[0];
	
	for (int i = 0; i < packetList->numPackets; i++) {
		
		for (int j = 0; j < packet->length; j+=3) {
			
            
			bool noteOn = false;
			bool noteOff = false;
			bool controlChange;
			bool pitchbend = false;
			int channel = -1;
			int number = -1;
			int value = -1;
			
			if(packet->data[0+j] >= 144 && packet->data[0+j] <= 159){
				noteOn = true;
				channel = packet->data[0+j] - 143;
				number = packet->data[1+j];
				value = packet->data[2+j];
			}
			if(packet->data[0+j] >= 128 && packet->data[0+j] <= 143){
				noteOff = true;
				channel = packet->data[0+j] - 127;
				number = packet->data[1+j];
				value = 0; //packet->data[2+j];
			}
			if(packet->data[0+j] >= 176 && packet->data[0+j] <= 191){
				if(packet->data[2+j] < 128){
					controlChange = true;
					channel = packet->data[0+j] - 175;
					number = packet->data[1+j];
					value = packet->data[2+j];
				}
			}
			if(packet->data[0+j] >= 224 && packet->data[0+j] <= 239){
				pitchbend = true;
				channel = packet->data[0+j] - 223;
				value =  packet->data[1+j] + packet->data[2+j]*127;
				pitchBends[channel-1] = value; 
			}
            if(packet->data[0+j] == 241){
                // MTC 
                // http://www.compeng.dit.ie/staff/tscarff/Music_technology/midi/MTC.htm                
                //
                int nnn = (packet->data[1+j] & 112)/16;
                int dddd = packet->data[1+j] & 15;
                
                switch (nnn) {
                    case 0:
                        mtcTimeTemp.frames = (mtcTimeTemp.frames & 0xF0) + dddd;
                        break;
                    case 1:
                        mtcTimeTemp.frames = (mtcTimeTemp.frames & 0xF) + dddd*0x10;
                        break;
                    case 2:
                        mtcTimeTemp.seconds = (mtcTimeTemp.seconds & 0xF0) + dddd;
                        break;
                    case 3:
                        mtcTimeTemp.seconds = (mtcTimeTemp.seconds & 0xF) + dddd*0x10;
                        break;
                    case 4:
                        mtcTimeTemp.minutes = (mtcTimeTemp.minutes & 0xF0) + dddd;
                        break;
                    case 5:
                        mtcTimeTemp.minutes = (mtcTimeTemp.minutes & 0xF) + dddd*0x10;
                        break;
                    case 6:
                        mtcTimeTemp.hours = (mtcTimeTemp.hours & 0xF) + dddd*0x10;
                        break;
                    case 7:
                    {
                        mtcTimeTemp.hours = (mtcTimeTemp.hours & 0xF) + (dddd&1)*0x10;
                        int f = (dddd&6)/2; 
                        if(f==0)
                            mtcTimeTemp.fps = 24;
                        if(f==1)             
                            mtcTimeTemp.fps = 25;
                        if(f==2)             
                            mtcTimeTemp.fps = 30; //(drop frame)
                        if(f==3)
                            mtcTimeTemp.fps = 30;                   
                        
                        mtcTime = mtcTimeTemp;
                        
                        [self setMtcTimeString:[NSString stringWithFormat:@"%i:%i:%i:%i @ %i fps",mtcTime.hours, mtcTime.minutes, mtcTime.seconds, mtcTime.frames, mtcTime.fps ]];
                        break;
                    }
                    default:
                        break;
                }
                
            }
			
			
			if([self isEnabled]){
				
				//pthread_mutex_lock(&mutex);
				
				//int rowIndex = 0;
				
				NSMutableDictionary * dict = [NSMutableDictionary dictionary];
				[dict setObject:[NSNumber numberWithInt:channel] forKey:@"channel"];
				[dict setObject:[NSNumber numberWithInt:number] forKey:@"number"];
				[dict setObject:[NSNumber numberWithInt:value] forKey:@"value"];				
				
				if(channel >= 0 && number >= 0){
					[[midiData objectAtIndex:channel] setObject:[NSNumber numberWithInt:value] forKey:[NSString stringWithFormat:@"%i", number]];
				}
				//				[[midiData objectForKey:[NSNumber numberWithInt:channel]] setObject:[NSNumber numberWithInt:value] forKey:[NSNumber numberWithInt:number]];
				
				//				[midiData setObject:[NSNumber numberWithInt:value] forKey:[NSString stringWithFormat:@"%i.%i", channel, number]];
				
				//				[self setMidiData:dict];
				
				//NSLog(@"%i %@", value, midiBindings);
				
				
				
				/* This caused a crash when receiving a midi packet sometimes! 
				 
				 [self willChangeValueForKey:@"midiData"];
				 [midiData setObject:[NSNumber numberWithInt:channel] forKey:@"channel"];
				 [midiData setObject:[NSNumber numberWithInt:number] forKey:@"number"];
				 [midiData setObject:[NSNumber numberWithInt:value] forKey:@"value"];				
				 [self didChangeValueForKey:@"midiData"];
				 
				 */
				
				//NSLog(@"%@",  midiData);
				
				/*for (dict in midiBindings){
				 
				 
				 if ([[dict objectForKey:@"channel"] intValue] == channel) {
				 if(controlChange){
				 
				 if ([[dict objectForKey:@"number"] intValue] == number) {
				 NSLog(@"%i", value);
				 PluginProperty * prop = (PluginProperty*) [[dict objectForKey:@"property"] intValue];
				 NSLog(@"%f", [prop floatValue]);
				 [prop midiEvent:value];
				 
				 }
				 }
				 }
				 }*/
				
				
				//pthread_mutex_unlock(&mutex);
			}
			
			/*
			 // handle plugin activation/deactivation
			 if (number == 1) {
			 
			 ofPlugin * p;
			 
			 for (p in [globalController plugins]) {
			 if ([p ] == channel) {
			 if (value == 0) {
			 [p setEnabled:[NSNumber numberWithInt:0]];
			 } else {
			 [p setEnabled:[NSNumber numberWithInt:1]];
			 }
			 }
			 }
			 
			 } 
			 
			 else if (number == 2) {
			 
			 ofPlugin * p;
			 
			 for (p in [globalController viewItems]) {
			 if ([p midiChannel] == channel) {
			 [p setAlpha:[NSNumber numberWithFloat:(value/127.0)]];
			 }
			 }
			 
			 } else if (number == 3) {
			 
			 ofPlugin * p;
			 
			 for (p in [globalController viewItems]) {
			 if ([p midiChannel] == channel) {
			 [p setMask:[NSNumber numberWithFloat:(value/127.0)]];
			 }
			 }
			 
			 } else {
			 
			 id theBinding;
			 
			 pthread_mutex_lock(&mutex);
			 
			 int rowIndex = 0;
			 
			 for (theBinding in boundControls){
			 if ([[theBinding channel] intValue] == channel) {
			 if(controlChange){
			 if ([[theBinding controller] intValue] == number) {
			 NSLog(@"%i", value);
			 [theBinding setSmoothingValue:[NSNumber numberWithInt:value] withTimeInterval: updateTimeInterval];
			 NSInteger row = [[boundControlsController arrangedObjects] indexOfObject:theBinding];
			 if (row != NSNotFound) {								
			 [rowIndexesChanged addIndex:row];
			 }
			 }
			 }
			 }
			 rowIndex++;
			 }
			 
			 [self performSelectorOnMainThread:@selector(_reloadRows:) withObject:rowIndexesChanged waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
			 
			 pthread_mutex_unlock(&mutex);
			 }
			 
			 }*/
		}	
		packet = MIDIPacketNext (packet);
	}
	//[[[controller controlPanel] midiStatus] setState:NSOnState];
	//[rowIndexesChanged release];
}
/*
 - (void)_reloadRows:(id)dirtyRows {
 pthread_mutex_lock(&mutex);
 [midiMappingsList reloadDataForRowIndexes:dirtyRows columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 7)]];
 pthread_mutex_unlock(&mutex);
 }*/


-(void) buildMidiInterfacePopUp{
	
	id endpointIterator;
	
	[midiInterface selectItem:nil];
	[midiInterface removeAllItems];
	[midiInterface setAutoenablesItems:NO];
	
	for (endpointIterator in [manager realSources]) {
		[midiInterface addItemWithTitle:[endpointIterator displayName]];
		[[midiInterface lastItem] setRepresentedObject:endpointIterator];
		[[midiInterface lastItem] setEnabled:YES];
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([[endpointIterator displayName] isEqualToString:[userDefaults stringForKey:@"midi.interface"]]){
				[midiInterface selectItem:[midiInterface lastItem]];
				endpoint = endpointIterator;
				[endpoint addReceiver:self];
			}
		}
	}
	
	for (endpointIterator in [manager realDestinations]) {
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([[endpointIterator displayName] isEqualToString:[userDefaults stringForKey:@"midi.interface"]]){
				sendEndpoint = endpointIterator;
			}
		}
	}
	
	
	if([midiInterface numberOfItems] == 0){
		[midiInterface addItemWithTitle:@"No midi interfaces found"];
		[midiInterface selectItem:[midiInterface lastItem]];
		[midiInterface setEnabled:NO];
	} else {
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([midiInterface indexOfItemWithTitle:[userDefaults stringForKey:@"midi.interface"]] == -1){
				[midiInterface addItemWithTitle: [[userDefaults stringForKey:@"midi.interface"] stringByAppendingString:@" (offline)"] ];
				[[midiInterface lastItem] setEnabled:NO];
				[midiInterface selectItem:[midiInterface lastItem]];
			}
		}
		[midiInterface setEnabled:YES];
	}
}

-(BOOL) willDraw:(NSMutableDictionary*)drawingInformation{
	return NO;	
}

-(IBAction) selectMidiInterface:(id)sender{
	endpoint = [[sender selectedItem] representedObject];
	
	id endpointIterator;
	for (endpointIterator in [manager realDestinations]) {
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([[endpointIterator displayName] isEqualToString:[endpoint displayName]]){
				sendEndpoint = endpointIterator;
			}
		}
	}
	
	
	[endpoint addReceiver:self];
	[userDefaults setValue:[sender titleOfSelectedItem] forKey:@"midi.interface"];
	NSLog(@"Select midi interface");
}


-(void)midiSetupChanged {
	[self buildMidiInterfacePopUp];
}

-(void)sendValue:(int)midiValue forNote:(int)midiNote onChannel:(int)_midiChannel{
	
	MIDIPacketList packetlist;
	MIDIPacket     *packet     = MIDIPacketListInit(&packetlist);
	Byte mdata[3] = {(143+_midiChannel), midiNote, midiValue};
	packet = MIDIPacketListAdd(&packetlist, sizeof(packetlist),
							   packet, 0, 3, mdata);
	cout<<"Prepare midi send"<<packet<<"  "<<midiValue<<"   "<<midiNote<<"   "<<_midiChannel<<endl;
	if (endpoint) {
		[sendEndpoint addSender:self];
		[sendEndpoint processMIDIPacketList:&packetlist sender:self];
		[sendEndpoint removeSender:self];
		cout<<"Midi send"<<packet<<"  "<<midiValue<<"   "<<midiNote<<"   "<<_midiChannel<<endl;
	}
	
}

-(IBAction) sendGo:(id)sender{
    MIDIPacketList packetlist;
	MIDIPacket     *packet     = MIDIPacketListInit(&packetlist);
	
	//	F0 7F <device_ID> 02 <command_format> <command> <data> F7
	// http://www.richmondsounddesign.com/docs/midi-show-control-specification.pdf
	
	Byte mdata[7] = {0xf0, 0x7f, [mscDeviceID intValue], 0x02, 0x7F, 0x01, 0xf7};
	packet = MIDIPacketListAdd(&packetlist, sizeof(packetlist),
							   packet, 0, 7, mdata);
	
	if (endpoint) {
		[sendEndpoint addSender:self];
		[sendEndpoint processMIDIPacketList:&packetlist sender:self];
		[sendEndpoint removeSender:self];
	}
}

-(IBAction) testNoteOn:(id)sender{
	[self sendValue:1 forNote:1 onChannel:1];
}


-(IBAction) sendResetAll:(id)sender{
	//	[self sendValue:1 forNote:1 onChannel:1];
	
	MIDIPacketList packetlist;
	MIDIPacket     *packet     = MIDIPacketListInit(&packetlist);
	
	//	F0 7F <device_ID> 02 <command_format> <command> <data> F7
	// http://www.richmondsounddesign.com/docs/midi-show-control-specification.pdf
	
	Byte mdata[7] = {0xf0, 0x7f, [mscDeviceID intValue] , 0x02, 0x7F, 0x0A, 0xf7};
	packet = MIDIPacketListAdd(&packetlist, sizeof(packetlist),
							   packet, 0, 7, mdata);
	
	if (endpoint) {
		[sendEndpoint addSender:self];
		[sendEndpoint processMIDIPacketList:&packetlist sender:self];
		[sendEndpoint removeSender:self];
	}
}

-(IBAction) printMidiMappingsList:(id)sender{
	[midiMappingsListForPrint reloadData];
	
	[[NSPrintInfo sharedPrintInfo] setHorizontalPagination:NSFitPagination];
	[[NSPrintInfo sharedPrintInfo] setVerticalPagination:NSAutoPagination];
	
	
	NSPrintOperation *op = [NSPrintOperation
							printOperationWithView:midiMappingsListForPrint
							printInfo:[NSPrintInfo sharedPrintInfo]];
	[op runOperationModalForWindow:[[NSApplication sharedApplication] mainWindow]
						  delegate:self
					didRunSelector:nil
					   contextInfo:NULL];
	
}

/*-(void) bindPluginUIControl:(PluginUIMidiBinding*)binding {
 pthread_mutex_lock(&mutex);
 
 [boundControls removeObjectIdenticalTo:binding];
 
 id theBinding;
 for (theBinding in [boundControlsController arrangedObjects]){
 if ([[theBinding channel] intValue] == [[binding channel] intValue]) {
 if ([[theBinding controller] intValue] == [[binding controller] intValue]) {
 
 NSLog(@"CONFLICT: %@ and %@ \n %i, %i    %i, %i", [binding label], [theBinding label], [[binding channel] intValue], [[binding controller] intValue], [[theBinding channel] intValue], [[theBinding controller] intValue] );
 
 [theBinding setConflict:YES];
 [binding setConflict:YES];
 showMidiConflictAlert = YES;
 [NSObject cancelPreviousPerformRequestsWithTarget:self];
 [self performSelector:@selector(showConflictSheet) withObject:nil afterDelay:1.0];
 }
 }
 }
 
 [boundControlsController addObject:[binding retain]];
 
 pthread_mutex_unlock(&mutex);
 }
 
 -(void) unbindPluginUIControl:(PluginUIMidiBinding*)binding {
 pthread_mutex_lock(&mutex);
 
 [boundControls removeObjectIdenticalTo:binding];
 
 id theBinding;
 for (theBinding in boundControls){
 if ([[theBinding channel] intValue] == [[binding channel] intValue]) {
 if ([[theBinding controller] intValue] == [[binding controller] intValue]) {
 [binding setConflict:NO];
 }
 }
 }
 
 pthread_mutex_unlock(&mutex);
 }*/

-(NSString*) getAppleScriptConnectionString{
	return [[NSString alloc] initWithFormat:@"eppc://%@:%@@%@", [appleScriptUsername stringValue], [appleScriptPassword stringValue], [appleScriptMachine stringValue] ]; 
}

-(float) getPitchBend:(int)channel{
	return pitchBends[channel];
}

@end