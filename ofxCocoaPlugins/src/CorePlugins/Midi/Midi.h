
#pragma once


#include "Plugin.h"

#include "PYMIDI.h"

struct MTCTime {
    int frames;
    int seconds;
    int minutes;
    int hours;
    int fps;
};

@interface Midi : ofPlugin <NSTableViewDataSource> {
	
	pthread_mutex_t mutex;

	NSUserDefaults				* userDefaults;
	
	IBOutlet NSTableView		* midiMappingsList;
	IBOutlet NSTableView		* midiMappingsListForPrint;
	IBOutlet NSView				* printHeaderView;
	IBOutlet NSPopUpButton		* midiInterface;
	IBOutlet NSTextField		* mscDeviceID;
	IBOutlet NSTextField		* appleScriptMachine;
	IBOutlet NSTextField		* appleScriptUsername;
	IBOutlet NSSecureTextField	* appleScriptPassword;
	
	CFTimeInterval			updateTimeInterval;
	CFTimeInterval			midiTimeInterval;
	
	PYMIDIManager				* manager;
	PYMIDIVirtualSource			* endpoint;
	PYMIDIVirtualDestination	* sendEndpoint;
	
	PYMIDIVirtualEndpoint		* virtualDestination;
	
	IBOutlet NSArrayController	* boundControlsController;
	NSMutableArray				* boundControls;
	
	bool					midiInterfaceSelectionFound;
	bool					updateView;
	bool					showMidiConflictAlert;
	bool					didShowMidiConflictAlert;
	
	//New one
	NSMutableArray * midiBindings;	
	NSMutableArray * midiData;
	
	float pitchBends[16];
    
    MTCTime mtcTime, mtcTimeTemp;
	NSString * mtcTimeString;
    
    ofSerial * serial;
    bool serialConnected;
}

@property (assign) NSMutableArray * boundControls;
@property (assign) NSMutableArray * midiBindings;
@property (assign) NSMutableArray * midiData;

@property (readwrite) NSString * mtcTimeString;

-(IBAction) selectMidiInterface:(id)sender;
-(IBAction) printMidiMappingsList:(id)sender;
-(IBAction) sendGo:(id)sender;
-(IBAction) sendResetAll:(id)sender;
-(IBAction) testNoteOn:(id)sender;

-(void)sendValue:(int)midiValue forNote:(int)midiNote onChannel:(int)midiChannel;

-(void) buildMidiInterfacePopUp;
-(void) midiSetupChanged;
//-(void) bindPluginUIControl:(PluginUIMidiBinding*)binding;
//	[pluginManagerController addPlugin:[[Cameras alloc] initWithNumberCameras:4]];-(void) unbindPluginUIControl:(PluginUIMidiBinding*)binding;

-(void) showConflictSheet;
- (IBAction)showSelectedControl:(id)sender;
- (void)willEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)didEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

-(NSString*) getAppleScriptConnectionString;

//-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(float) getPitchBend:(int)channel;

-(MTCTime) getMTCTime;
-(float) getMTCSeconds;

@end