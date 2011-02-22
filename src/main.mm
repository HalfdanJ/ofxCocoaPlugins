#import "GLee.h"
#import <Cocoa/Cocoa.h>

#include "ofAppCocoaWindow.h"

#define BOOL OFBOOL    // work around
#include "ofMain.h"
#undef BOOL     // work around




int main(int argc, char *argv[])
{
	ofAppCocoaWindow window;
	window.setUseFSAA(true);
    ofSetupOpenGL(&window, 800, 600, OF_WINDOW);
	
	ofRunApp( new ofBaseApp() );	
}
