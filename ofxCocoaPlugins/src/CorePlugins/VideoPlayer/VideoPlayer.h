#pragma once

#import <ofxCocoaPlugins/Plugin.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <QTKit/QTKit.h>

@class QTMovie;
#define NUMVIDEOS 127

@interface VideoPlayer : ofPlugin {
	QTMovie     		*movie[NUMVIDEOS];
	QTVisualContextRef	textureContext[NUMVIDEOS];
	CVOpenGLTextureRef  currentFrame[NUMVIDEOS];
	NSSize sizes[NUMVIDEOS];
	
	int lastFramesVideo;
	BOOL forceDrawNextFrame;

	NSMutableArray * loadedFiles;
	IBOutlet NSArrayController * loadedFilesController;
	
	IBOutlet NSPopUpButton * videoSelector;
	IBOutlet NSPopUpButton * chapterSelector;
}

@property (readwrite, retain) NSMutableArray * loadedFiles;
-(IBAction) restart:(id)sender;
@end
