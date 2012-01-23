#include <ofxCocoaPlugins/Plugin.h>
#include <ofxCocoaPlugins/PluginProperty.h>
#include <ofxCocoaPlugins/QLab.h>

@interface CueObject : NSObject
{
	QLabCue * cue;
	NSString * name;
	PluginProperty * property;
	
	int channel;
	NSNumber * duration;
	int endvalue;
	BOOL fade;
	int startvalue;
	int number;
	
	NSDictionary * originalDict;
	
	BOOL updateStartvalue;
}
@property (readwrite) 	int channel;
@property (readwrite) 	int number;
@property (readwrite) 	int startvalue;
@property (readwrite) 	int endvalue;
@property (readwrite) 	BOOL fade;
@property (readwrite) 	BOOL updateStartvalue;
@property (retain, readwrite) QLabCue * cue;
@property (retain, readwrite) NSString * name;
@property (retain, readwrite) NSNumber * duration;
@property (retain, readwrite) PluginProperty * property;

@property (readwrite) int actualEndvalue;

@property (readwrite, retain)NSDictionary * originalDict; 
@property (readonly) BOOL undefinedCue;

-(void) restoreStartvalue;
-(void) restoreEndvalue;
-(int) originalActualEndvalue;
-(void) updateName;

@end



@interface QLabController : NSObject {
	IBOutlet NSPanel * panel;
	
	IBOutlet NSTextField * prevName;
	IBOutlet NSTextField * thisName;
	IBOutlet NSTextField * nextName;
	
	IBOutlet NSTextField * prevStart;
	IBOutlet NSTextField * thisStart;
	IBOutlet NSTextField * nextStart;
	
	IBOutlet NSTextField * prevEnd;
	IBOutlet NSTextField * thisEnd;
	IBOutlet NSTextField * nextEnd;
	
	IBOutlet NSButton * updateCheck;
	IBOutlet NSButton * takeButton;
	IBOutlet NSButton * zeroButton;
	IBOutlet NSButton * nextUpdateButton;
	
	IBOutlet NSButton * okButton;
	IBOutlet NSButton * cancelButton;	
	
	PluginProperty * linkedProperty;
	
	QLabCue * prevCue;
	QLabCue * thisCue;
	QLabCue * nextCue;
	
	CueObject * prevCueDict;
	CueObject * thisCueDict;
	CueObject * nextCueDict;
	
	BOOL multipleSelection;
	
	CueObject * shownPrevCueDict;
	CueObject * shownThisCueDict;
	CueObject * shownNextCueDict;
	
	NSThread * thread;
	BOOL blinkRunning;
	BOOL blink;

	
	BOOL fadeAllowed;
	BOOL verbose;
}
@property (readwrite,retain) PluginProperty * linkedProperty;
@property (readwrite,retain) CueObject * shownPrevCueDict;
@property (readwrite,retain) CueObject * shownThisCueDict;
@property (readwrite,retain) CueObject * shownNextCueDict;


-(void) updateQlabForPlugin:(ofPlugin*) plugin;
-(void) startQlabTransaction:(PluginProperty*)proptery fadingAllowed:(BOOL)_fadeAllowed verbose:(BOOL)_verbose;

-(void) setMidiChannel:(int)channel number:(int)number forCue:(QLabCue*)cue;
-(NSDictionary*) getCueInfo:(QLabCue*)cue;



-(QLabApplication*) getQLab;
-(CueObject*) newCue;

-(void) blinkName;
-(void) stopBlink;

-(IBAction) setUpdateChecked:(id)sender;
-(IBAction) go:(id)sender;
-(IBAction) cancel:(id)sender;

//-(NSDictionary*) getThisCueDict;
//-(NSDictionary*) getNextCueDict;
//-(NSDictionary*) getPrevCueDict;

-(void) populateCueDict:(CueObject*)obj;
-(void) updateCue:(CueObject*)cue;
@end
