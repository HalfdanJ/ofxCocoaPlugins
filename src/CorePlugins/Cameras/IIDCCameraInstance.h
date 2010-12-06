#pragma once


#include "CameraInstance.h"
#include "Libdc1394Grabber.h"

@interface IIDCCameraInstance : CameraInstance {
	Libdc1394Grabber * videoGrabber;
	
	NSString * guid;
	
	NSRecursiveLock * lock;
	
	NSMutableDictionary * videoModes;
	NSDictionaryController * videoModesController;

	NSMutableDictionary * videoColorCodings;
	NSDictionaryController * videoColorCodingsController;

	NSMutableDictionary * videoFramerates;
	NSDictionaryController * videoFrameratesController;
	
	dc1394video_mode_t videoMode;
	dc1394color_coding_t videoColorCoding;
	dc1394framerate_t	videoFramerate;
	
	NSNumber * whitebalance1;
	NSNumber * whitebalance2;
	NSNumber * brightness;
	NSNumber * shutter;
	NSNumber * gain;

	NSNumber * gamma;
	BOOL disabled;
	BOOL hasBlacked;
}
@property (retain) NSNumber * whitebalance1;
@property (retain) NSNumber * whitebalance2;
@property (retain) NSNumber * brightness;
@property (retain) NSNumber * shutter;
@property (retain) NSNumber * gain;

@property (retain) NSNumber * gamma;

@property (retain) NSString * guid;

@property (readonly)Libdc1394Grabber * videoGrabber;
@property (retain) 	NSMutableDictionary * videoModes;
@property (retain) 	NSMutableDictionary * videoColorCodings;
@property (retain) 	NSMutableDictionary * videoFramerates;

@property (readwrite) dc1394video_mode_t videoMode;
@property (readwrite) dc1394color_coding_t videoColorCoding;
@property (readwrite) dc1394framerate_t	videoFramerate;

-(id)initWithGuid:(NSString*)guid;
- (void)videoGrabberRespawn;

-(BOOL) isFrameNew;

-(void)applyToAll;

@end
