
#pragma once
#include "GL/glew.h"

#import <Cocoa/Cocoa.h>

#define NUMBER_PROPERTY 1
#define STRING_PROPERTY 2
#define COLOR_PROPERTY 3
#define BOOL_PROPERTY 4




//@class GraphDebugger;
//extern GraphDebugger * globalGraphDebugger;

@interface PluginProperty : NSObject  <NSCoding, NSCopying> {
	id value;
	id defaultValue;
//	int type;
	int controlType;
	BOOL graphDebugging;
	NSString * name;
	NSString * pluginName;
	NSCell * controlCell;
	
//	NSMutableDictionary * midiProperties;
	
	NSNumber * midiChannel;
	NSNumber * midiNumber;
	BOOL binded;
	BOOL forcedMidiNumber;
}
@property (retain) NSString * name;
@property (retain) NSString * pluginName;

@property (retain) id value;
@property (retain) id defaultValue;
@property (readwrite) int controlType;
@property (readonly) BOOL forcedMidiNumber;

@property (retain, readwrite) NSNumber * graph;
@property (retain) NSCell * controlCell;
@property (retain)	NSNumber * midiChannel;
@property (retain)	NSNumber * midiNumber;

-(void) update;
-(void) midiEvent:(int) value;
-(void) bindMidi;
-(void) unbindMidi;

-(void) reset;
-(NSNumber*)midiValue;
-(void) sendQlab;
-(void) sendQlabNonVerbose;

-(void) setManualMidiNumber:(NSNumber*)number;

//-(void) sendQlabScriptName:(NSString*)description channel:(int)channel control:(int)control value:(int)value fade:(bool)fade;
//+(PluginProperty*)boolProperty:(BOOL)defValue;
//+(PluginProperty*)stringProperty:(NSString*)defValue;



@end
