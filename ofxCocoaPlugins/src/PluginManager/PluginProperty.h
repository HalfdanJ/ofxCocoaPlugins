#pragma once
#import <Cocoa/Cocoa.h>

#define NUMBER_PROPERTY 1
#define STRING_PROPERTY 2
#define COLOR_PROPERTY 3
#define BOOL_PROPERTY 4


@interface PluginProperty : NSObject  <NSCoding, NSCopying> {
	id value;
	id defaultValue;
	int controlType;
	NSString * name;
	NSString * pluginName;
	NSCell * controlCell;
	
	NSNumber * midiChannel;
	NSNumber * midiNumber;
	BOOL binded;
	BOOL forcedMidiNumber;
    NSString * midiLabel;
}
@property (retain) NSString * name;
@property (retain) NSString * pluginName;

@property (retain) id value;
@property (retain) id defaultValue;
@property (readwrite) int controlType;
@property (readwrite) BOOL forcedMidiNumber;

@property (retain) NSCell * controlCell;
@property (retain)	NSNumber * midiChannel;
@property (retain)	NSNumber * midiNumber;
@property (readwrite, retain) NSString * midiLabel;

-(void) update;
-(void) midiEvent:(int) value;
-(void) bindMidi;
-(void) unbindMidi;

-(void) reset;
-(NSNumber*)midiValue;
-(void) sendQlab;
-(void) sendQlabNonVerbose;

// Deprecated
// -(void) setManualMidiNumber:(NSNumber*)number; 


@end
