
#include "ofAppCocoaWindow.h"

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
	fps                     = 0.0f;
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



void ofAppCocoaWindow::keyPressed(int key){
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

int		ofAppCocoaWindow::getWidth(){ return windowW; }
int		ofAppCocoaWindow::getHeight(){ return windowH; }

ofPoint	ofAppCocoaWindow::getScreenSize() {
	return screenSize;
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


