
#include "ofAppCocoaWindow.h"

//#include "ofMain.h"
//#include <AppKit/AppKit.h>

static ofAppCocoaWindow * ofWindowPtr;

/*ofAppCocoaWindow* appWindow() {
    return ofWindowPtr;
}*/

/******** Constructor ************/

ofAppCocoaWindow::ofAppCocoaWindow() {
	nFrameCount				= 0;
	bEnableSetupScreen		= true;
	
	windowPos.set(0, 0);
	windowSize.set(0, 0);
	screenSize.set(0, 0);
	
	
	bNewScreenSize		= false;
	bNewScreenPosition	= false;
	bNewWindowString	= true;
	
	nFrameCount				= 0;
	windowMode				= 0;
	bNewScreenMode			= false;
	timeNow, timeThen, fps	= 0.0f;
	nFramesForFPS			= 2;
	nFrameCount				= 0;
	buttonInUse				= 0;
	bEnableSetupScreen		= false;

	bFrameRateSet			= false;
	millisForFrame			= 0;
	prevMillis				= 0;
	diffMillis				= 0;

	frameRate				= 100.0;
	frameRateGoal			= 100.0;

	nonFullScreenX = 0 ;
	nonFullScreenY = 0;
	
	windowString = "cocoa openFrameworks";
	
	bFSAA = false;
}

void ofAppCocoaWindow::setUseFSAA(bool useFSAA) {
	bFSAA = useFSAA;
}

/******** Initialization methods ************/

void ofAppCocoaWindow::setupOpenGL(int w, int h, int screenMode) {
	windowMode		= screenMode;
	if( windowMode != OF_WINDOW )bNewScreenMode	= true;

	requestedWidth	= w;
	requestedHeight = h;
	
	windowW = 320;
	windowH = 240;
	
}


void ofAppCocoaWindow::initializeWindow() {

}


void  ofAppCocoaWindow::runAppViaInfiniteLoop(ofBaseApp * appPtr) {
	
	ofWindowPtr = this;
	
	ofGetAppPtr()->mouseX = 0;
	ofGetAppPtr()->mouseY = 0;


 //   return NSApplicationMain(argc, (const char **)argv);

	//NSApplicationMain(0,  NULL);

}

void ofAppCocoaWindow::setup( )
{
	//OFSAptrForCocoa->setup();
}

void ofAppCocoaWindow::update(){	
	ofGetAppPtr()->update();
}

void ofAppCocoaWindow::render(int width, int height){
	
}


void ofAppCocoaWindow::keyPressed(int key){
	if(key == OF_KEY_ESC){
//		OF_EXIT_APP(0);
		ofSetFullscreen(false);
	}
	
	ofGetAppPtr()->keyPressed(key);
}

void ofAppCocoaWindow::mousePressed(float x, float y, int button){
	ofGetAppPtr()->mousePressed(x, windowH-y, button);
	ofGetAppPtr()->mouseX = x;
	ofGetAppPtr()->mouseY = windowH-y;
}

void ofAppCocoaWindow::mouseDragged(float x, float y, int button){
	ofGetAppPtr()->mouseDragged(x, windowH-y, button);
	ofGetAppPtr()->mouseX = x;
	ofGetAppPtr()->mouseY = windowH-y;
}

void ofAppCocoaWindow::mouseReleased(int button){
	ofGetAppPtr()->mouseReleased(ofGetAppPtr()->mouseX, ofGetAppPtr()->mouseY, button);
}


void ofAppCocoaWindow::mouseMoved(float x, float y){
	ofGetAppPtr()->mouseMoved(x, windowH-y);
	ofGetAppPtr()->mouseX = x;
	ofGetAppPtr()->mouseY = windowH-y;
}


/******** Set Window properties ************/

void ofAppCocoaWindow::setWindowPosition(int x, int y) {
	requestedX = x;
	requestedY = y;
	bNewScreenPosition = true;
}

void ofAppCocoaWindow::setWindowShape(int w, int h) {
    windowW = w;
    windowH = h;
}



/******** Get Window/Screen properties ************/

// return cached pos, read if nessecary
ofPoint	ofAppCocoaWindow::getWindowPosition() {
	return ofPoint(windowX, windowY);
}


ofPoint	ofAppCocoaWindow::getWindowSize() {
	return ofPoint(windowW, windowH,0);
}

ofPoint	ofAppCocoaWindow::getScreenSize() {
	return screenSize;
}

int	ofAppCocoaWindow::getWindowMode() {
	return windowMode;
}

float ofAppCocoaWindow::getFrameRate() {
	return (float)frameRate;
}

/******** Other stuff ************/
void ofAppCocoaWindow::setFrameRate(float targetRate) {
	frameRate = targetRate;
	frameRateGoal = targetRate;
}

int	ofAppCocoaWindow::getFrameNum() {
	return nFrameCount;
}

void ofAppCocoaWindow::setWindowTitle(string title) {
//	[[[NSApplication sharedApplication] mainWindow] setTitle:[NSString stringWithCString:title.c_str()]];
}


void ofAppCocoaWindow::setFullscreen(bool fullscreen) {
	
	if(fullscreen) windowMode		= OF_FULLSCREEN;
	else windowMode					= OF_WINDOW;
	
	bNewScreenMode					= true;
}

void ofAppCocoaWindow::toggleFullscreen() {
	if(windowMode == OF_FULLSCREEN) setFullscreen(false);
	else setFullscreen(true);
}


void ofAppCocoaWindow::enableSetupScreen(){
	bEnableSetupScreen = true;
};

void ofAppCocoaWindow::disableSetupScreen(){
	bEnableSetupScreen = false;
};


