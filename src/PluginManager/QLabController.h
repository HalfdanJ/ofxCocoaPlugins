#include "Plugin.h"
#include "PluginProperty.h"
#include "QLab.h"


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
	
	
	PluginProperty * linkedProperty;
	
	QLabCue * prevCue;
	QLabCue * thisCue;
	QLabCue * nextCue;
	
	NSMutableDictionary * prevCueDict;
	NSMutableDictionary * thisCueDict;
	NSMutableDictionary * nextCueDict;
	
	BOOL multipleSelection;
	
	NSDictionary * shownPrevCueDict;
	NSDictionary * shownThisCueDict;
	NSDictionary * shownNextCueDict;
	
}
@property (readwrite,retain) PluginProperty * linkedProperty;
@property (readwrite,retain) NSDictionary * shownPrevCueDict;
@property (readwrite,retain) NSDictionary * shownThisCueDict;
@property (readwrite,retain) NSDictionary * shownNextCueDict;


-(void) updateQlabForPlugin:(ofPlugin*) plugin;
-(void) startQlabTransaction:(PluginProperty*)proptery;

-(void) setMidiChannel:(int)channel number:(int)number forCue:(QLabCue*)cue;

-(QLabApplication*) getQLab;
-(NSMutableDictionary*) newCue;

-(IBAction) setUpdateChecked:(id)sender;

-(NSDictionary*) getThisCueDict;
-(NSDictionary*) getNextCueDict;
-(NSDictionary*) getPrevCueDict;
@end
