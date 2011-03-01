/*
 * Qlab.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class QlabItem, QlabApplication, QlabColor, QlabDocument, QlabWindow, QlabWorkspace, QlabCue, QlabGroupCue, QlabCueList, QlabAudioCue, QlabFadeCue, QlabVideoCue, QlabAnimationCue, QlabCameraCue, QlabMidiCue, QlabMscCue, QlabMidiSysexCue, QlabMtcCue, QlabDevampCue, QlabLoadCue, QlabTargetCue;

typedef enum {
	QlabSaveOptionsYes = 'yes ' /* Save the file. */,
	QlabSaveOptionsNo = 'no  ' /* Do not save the file. */,
	QlabSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
} QlabSaveOptions;

typedef enum {
	QlabEnabledDisabledEnabled = 'Yyes',
	QlabEnabledDisabledDisabled = 'Nnoo'
} QlabEnabledDisabled;

// Continue mode of a cue.
typedef enum {
	QlabContinueModesDo_not_continue = 'NoCo' /* Do not automatically continue to the next cue. */,
	QlabContinueModesAuto_continue = 'DoCo' /* Automatically continue to the next cue after completing the post wait. */,
	QlabContinueModesAuto_follow = 'DoFo' /* Automatically continue to the next cue after completing the action of the cue. */
} QlabContinueModes;

typedef enum {
	QlabGroupModesCue_list = 'qGCL' /* The group is a cue list. */,
	QlabGroupModesFire_first_enter_group = 'qGSS' /* Fire first child and enter into group. */,
	QlabGroupModesFire_first_go_to_next_cue = 'qGHS' /* Fire first child and go to next cue. */,
	QlabGroupModesFire_all = 'qGFA' /* Fire all children simultaneously. */,
	QlabGroupModesFire_random = 'qGFR' /* Fire a random child cue and then go to the next cue. */
} QlabGroupModes;

// SMPTE timecode format.
typedef enum {
	QlabSmpteFormat24_fps = '24FP' /* 24 frames per second */,
	QlabSmpteFormat25_fps = '25FP' /* 25 frames per second */,
	QlabSmpteFormat30_fps_drop = '30DR' /* 30 frames per second (drop frame) */,
	QlabSmpteFormat30_fps_non_drop = '30ND' /* 30 frames per second (non-drop) */
} QlabSmpteFormat;

typedef enum {
	QlabAbsoluteRelativeAbsolute = 'ABSO',
	QlabAbsoluteRelativeRelative = 'RELA'
} QlabAbsoluteRelative;

typedef enum {
	QlabMtcLtcMtc = 'synM' /* MIDI Timecode */,
	QlabMtcLtcLtc = 'synL' /* Linear / Logitudinal Timecode */
} QlabMtcLtc;

typedef enum {
	QlabMidiCommandNote_on = 'NtOn' /* Note on. */,
	QlabMidiCommandNote_off = 'NtOf' /* Note off. */,
	QlabMidiCommandProgram_change = 'PrCh' /* Program change. */,
	QlabMidiCommandControl_change = 'CtCh' /* Control change. */,
	QlabMidiCommandKey_pressure = 'KyPr' /* Key pressure (aftertouch). */,
	QlabMidiCommandChannel_pressure = 'ChPr' /* Channel pressure. */,
	QlabMidiCommandPitch_bend = 'PiBe' /* Pitch bend (pitch wheel). */
} QlabMidiCommand;



/*
 * Standard Suite
 */

// A scriptable object.
@interface QlabItem : SBObject

@property (copy) NSDictionary *properties;  // All of the object's properties.

- (void) closeSaving:(QlabSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSURL *)in_ as:(NSString *)as;  // Save an object.
- (void) loadTime:(double)time;  // Load a cue or workspace to a given time.
- (void) go;  // Make a workspace GO.
- (void) start;  // Start one or more cues or workspaces.
- (void) pause;  // Pause one or more cues or workspaces.
- (void) stop;  // Stop one or more cues or workspaces.
- (void) reset;  // Reset one or more cues or workspaces.
- (void) moveSelectionUp;  // Select the previous cue.
- (void) moveSelectionDown;  // Select the next cue.

@end

// An application's top level scripting object.
@interface QlabApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) workspaces;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *version;  // The version of the application.

- (void) open:(NSURL *)x;  // Open an object.
- (void) print:(NSURL *)x;  // Print an object.
- (void) quitSaving:(QlabSaveOptions)saving;  // Quit an application.

@end

// A color.
@interface QlabColor : SBObject

- (void) closeSaving:(QlabSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSURL *)in_ as:(NSString *)as;  // Save an object.
- (void) loadTime:(double)time;  // Load a cue or workspace to a given time.
- (void) go;  // Make a workspace GO.
- (void) start;  // Start one or more cues or workspaces.
- (void) pause;  // Pause one or more cues or workspaces.
- (void) stop;  // Stop one or more cues or workspaces.
- (void) reset;  // Reset one or more cues or workspaces.
- (void) moveSelectionUp;  // Select the previous cue.
- (void) moveSelectionDown;  // Select the next cue.

@end

// A document.
@interface QlabDocument : SBObject

@property (copy) NSString *path;  // The document's path.
@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *name;  // The document's name.

- (void) closeSaving:(QlabSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSURL *)in_ as:(NSString *)as;  // Save an object.
- (void) loadTime:(double)time;  // Load a cue or workspace to a given time.
- (void) go;  // Make a workspace GO.
- (void) start;  // Start one or more cues or workspaces.
- (void) pause;  // Pause one or more cues or workspaces.
- (void) stop;  // Stop one or more cues or workspaces.
- (void) reset;  // Reset one or more cues or workspaces.
- (void) moveSelectionUp;  // Select the previous cue.
- (void) moveSelectionDown;  // Select the next cue.

@end

// A window.
@interface QlabWindow : SBObject

@property (copy) NSString *name;  // The full title of the window.
- (NSNumber *) id;  // The unique identifier of the window.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (copy, readonly) QlabDocument *document;  // The document whose contents are being displayed in the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (readonly) BOOL titled;  // Whether the window has a title bar.
@property (copy) NSNumber *index;  // The index of the window in the back-to-front window ordering.
@property (readonly) BOOL floating;  // Whether the window floats.
@property (readonly) BOOL miniaturizable;  // Whether the window can be miniaturized.
@property BOOL miniaturized;  // Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  // Whether the window is the application's current modal window.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.

- (void) closeSaving:(QlabSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSURL *)in_ as:(NSString *)as;  // Save an object.
- (void) loadTime:(double)time;  // Load a cue or workspace to a given time.
- (void) go;  // Make a workspace GO.
- (void) start;  // Start one or more cues or workspaces.
- (void) pause;  // Pause one or more cues or workspaces.
- (void) stop;  // Stop one or more cues or workspaces.
- (void) reset;  // Reset one or more cues or workspaces.
- (void) moveSelectionUp;  // Select the previous cue.
- (void) moveSelectionDown;  // Select the next cue.

@end



/*
 * QLab Suite
 */

// A QLab workspace.
@interface QlabWorkspace : QlabDocument

@property (copy, readonly) NSMutableArray * selected;

- (SBElementArray *) cueLists;
- (SBElementArray *) cues;


@end

// A cue.
@interface QlabCue : SBObject

- (SBElementArray *) cues;

@property (copy, readonly) NSString *uniqueID;  // The unique ID of the cue.
@property (copy, readonly) NSString *qType;  // The name of this kind of cue, e.g. "Audio", "Video", "MIDI", etc.
@property (copy) NSString *qNumber;  // The number of the cue. Unique if present.
@property (copy) NSString *qName;  // The name of the cue. Not unique.
@property (copy) QlabCue *cueTarget;  // The cue this cue targets, if any.
@property (copy) NSURL *fileTarget;  // The file this cue targets, if any.
@property double preWait;  // The time in seconds before the action is triggered.
@property double duration;  // The duration of the cue in seconds.  Not editable for all cue types.
@property double postWait;  // The time in seconds until continuing on to the next cue.
@property QlabContinueModes continueMode;  // Continue mode of the cue.
@property BOOL armed;  // Is this cue armed?
@property QlabEnabledDisabled midiTrigger;  // State of the MIDI trigger.
@property QlabMidiCommand midiCommand;  // Type of MIDI command that will trigger the cue.
@property NSInteger midiByteOne;  // Byte 1 of the MIDI trigger.
@property NSInteger midiByteTwo;  // Byte 2 of the MIDI trigger.
@property QlabEnabledDisabled timecodeTrigger;  // State of the timecode trigger.
@property QlabEnabledDisabled wallClockTrigger;  // State of the wall clock trigger.
@property NSInteger wallClockHours;  // Hours field of the wall clock trigger.
@property NSInteger wallClockMinutes;  // Minutes field of the wall clock trigger.
@property NSInteger wallClockSeconds;  // Seconds field of the wall clock trigger.
@property (readonly) BOOL loaded;  // Is this cue loaded?
@property (readonly) BOOL running;  // Is this cue running?
@property (readonly) BOOL paused;  // Is this cue paused?
@property (readonly) BOOL broken;  // Is this cue broken?

- (void) closeSaving:(QlabSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveIn:(NSURL *)in_ as:(NSString *)as;  // Save an object.
- (void) loadTime:(double)time;  // Load a cue or workspace to a given time.
- (void) go;  // Make a workspace GO.
- (void) start;  // Start one or more cues or workspaces.
- (void) pause;  // Pause one or more cues or workspaces.
- (void) stop;  // Stop one or more cues or workspaces.
- (void) reset;  // Reset one or more cues or workspaces.
- (void) moveSelectionUp;  // Select the previous cue.
- (void) moveSelectionDown;  // Select the next cue.

@end

// A Group Cue.
@interface QlabGroupCue : QlabCue

@property QlabGroupModes mode;  // The firing style of this group.


@end

// A cue list.
@interface QlabCueList : QlabGroupCue

@property (copy) QlabCue *playbackPosition;  // The playback position of this cue list is the cue that will fire at the next GO.
@property QlabEnabledDisabled syncToTimecode;  // Sync the cues in this cue list to incoming timecode.
@property QlabMtcLtc syncMode;  // Which kind of incoming timecode this cue list listens for.
@property QlabSmpteFormat smpteFormat;  // SMPTE format of the incoming timecode.
@property (copy) NSString *mtcSyncSourceName;  // Name of the MIDI device which feeds us MTC timecode.
@property NSInteger ltcSyncChannel;  // Audio channel that carries the LTC signal.


@end

// An Audio Cue.
@interface QlabAudioCue : QlabCue

@property NSInteger patch;  // Audio device patch number.
@property double startTime;  // Time in the file where playback begins.
@property double endTime;  // Time in the file where playback ends.
@property double loopStartTime;  // Time in the file where the looping portion of the cue begins.
@property double loopEndTime;  // Time in the file where the looping portion of the cue ends.
@property NSInteger loopCount;  // Number of times the looped portion plays.  Always >= 1.
@property BOOL infiniteLoop;  // Does the cue loop infinitely?
@property QlabEnabledDisabled integratedFade;  // State of the integrated fade.


@end

// A Fade Cue.
@interface QlabFadeCue : QlabCue

@property QlabAbsoluteRelative mode;  // Absolute or relative mode.
@property BOOL stopTargetWhenDone;  // Do we stop the target when this cue completes?


@end

// A Video Cue.
@interface QlabVideoCue : QlabCue

@property NSInteger patch;  // Audio device patch number.
@property double startTime;  // Time in the file where playback begins.
@property double endTime;  // Time in the file where playback ends.
@property BOOL infiniteLoop;  // Does the cue loop infinitely?
@property BOOL autoStop;  // Does the cue automatically stop itself when the video finishes playing?
@property NSInteger layer;  // Display layer of the video.
@property BOOL fullScreen;  // Is the cue displaying in full screen mode?
@property BOOL preserveAspectRatio;  // Does the cue preserve aspect ratio in full screen mode?
@property double opacity;  // Video opacity.
@property double translationX;  // Translation along the x axis.
@property double translationY;  // Translation along the y axis.
@property double rotation;  // Rotation in degrees.
@property double scaleX;  // Scale along the x axis.
@property double scaleY;  // Scale along the y axis.
@property BOOL scaleLocked;  // Are the scale values forced to be equal?
@property BOOL customRendering;  // Does the cue render with a custom Quartz Composer file?


@end

// An Animation Cue.
@interface QlabAnimationCue : QlabCue

@property BOOL stopTargetWhenDone;  // Stop the target when this cue completes?
@property double opacity;  // Video opacity.
@property double translationX;  // Translation along the x axis.
@property double translationY;  // Translation along the y axis.
@property double rotation;  // Rotation in degrees.
@property double scaleX;  // Scale along the x axis.
@property double scaleY;  // Scale along the y axis.
@property BOOL scaleLocked;  // Are the scale values forced to be equal?
@property BOOL doOpacity;  // Does the cue animate opacity?
@property BOOL doTranslation;  // Does the cue animate translation?
@property BOOL doRotation;  // Does the cue animate rotation?
@property BOOL doScale;  // Does the cue animate scale?


@end

// A Camera Cue.
@interface QlabCameraCue : QlabCue

@property NSInteger patch;  // Camera patch number.
@property NSInteger layer;  // Display layer of the video.
@property BOOL fullScreen;  // Is the cue displaying in full screen mode?
@property BOOL preserveAspectRatio;  // Does the cue preserve aspect ratio in full screen mode?
@property double opacity;  // Video opacity.
@property double translationX;  // Translation along the x axis.
@property double translationY;  // Translation along the y axis.
@property double rotation;  // Rotation in degrees.
@property double scaleX;  // Scale along the x axis.
@property double scaleY;  // Scale along the y axis.
@property BOOL scaleLocked;  // Are the scale values forced to be equal?
@property BOOL customRendering;  // Does the cue render with a custom Quartz Composer file?


@end

// A MIDI Cue.
@interface QlabMidiCue : QlabCue

@property NSInteger patch;  // MIDI device patch number.
@property QlabMidiCommand command;  // The MIDI command.
@property NSInteger channel;  // MIDI channel number.
@property NSInteger byteOne;  // First byte of the message.
@property NSInteger byteTwo;  // Second byte of the message.
@property NSInteger byteCombo;  // Value when first and second bytes are interpreted as parts of one number.  Used for pitch bend messages.
@property (readonly) NSInteger startValue;  // The start value for the MIDI fade.
@property NSInteger endValue;  // The end value for the MIDI fade.
@property QlabEnabledDisabled fade;  // State of the MIDI fade.


@end

// An MSC Cue.
@interface QlabMscCue : QlabCue

@property NSInteger patch;  // MIDI device patch number.
@property NSInteger commandFormat;  // MIDI Show Control command format.
@property NSInteger command;  // MIDI Show Control command.
@property (copy) NSString *q_number;  // Q Number message parameter.
@property (copy) NSString *q_list;  // Q List message parameter.
@property (copy) NSString *q_path;  // Q Path message parameter.
@property NSInteger macro;  // MSC macro.
@property NSInteger controlNumber;  // MSC control number.
@property NSInteger controlValue;  // MSC control value.
@property NSInteger hours;  // MSC hours parameter.
@property NSInteger minutes;  // MSC minutes parameter.
@property NSInteger seconds;  // MSC seconds parameter.
@property NSInteger frames;  // MSC frames parameter.
@property NSInteger subframes;  // MSC subframes parameter.
@property QlabSmpteFormat smpteFormat;  // SMPTE format of the timecode parameters.
@property BOOL sendTimeWithSet;  // Send the timecode parameters with the SET command?


@end

// A MIDI SysEx Cue.
@interface QlabMidiSysexCue : QlabCue

@property NSInteger patch;  // MIDI device patch number.
@property (copy) NSString *sysexMessage;  // The raw SysEx message.  Use only hexadecimal characters and whitespace.  Omit the starting F0 and the ending F7.


@end

// An MTC Cue.
@interface QlabMtcCue : QlabCue

@property (copy) NSString *midiDestination;  // Name of the destination MIDI device.
@property QlabSmpteFormat smpteFormat;  // SMPTE format of the outgoing timecode.
@property double startTime;  // Time in seconds where the MTC clock begins counting.


@end

// A Devamp Cue.
@interface QlabDevampCue : QlabCue

@property BOOL fireNextCueWhenLoopEnds;  // Fire the next cue at the moment the target loop ends?
@property BOOL stopTargetWhenLoopEnds;  // Stop the target at the moment the target loop ends?


@end

// A Load Cue.
@interface QlabLoadCue : QlabCue

@property double loadTime;  // Load target cue to this time.


@end

// A Target Cue.
@interface QlabTargetCue : QlabCue

@property (copy) NSString *assignedNumber;  // Number of cue to assign.  The cue with this number will be assigned as the new target.


@end

