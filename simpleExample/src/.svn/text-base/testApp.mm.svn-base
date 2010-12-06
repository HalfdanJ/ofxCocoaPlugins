
#import "GLee.h"
#import <Cocoa/Cocoa.h>

#include "testApp.h"


//--------------------------------------------------------------

testApp::testApp(): ofBaseApp() {
	setupCalled = false;
	
}

//--------------------------------------------------------------


void testApp::setup(){	

	ofSetWindowTitle("OpenFrameworks - Fuck You Buddy");
	
	ofSetLogLevel(OF_LOG_VERBOSE);
	ofLog(OF_LOG_VERBOSE, "TestApp setup");

	ofSetDataPathRoot("data/");
	lucidaGrande.loadFont("LucidaGrande.ttc",22, false, true);
	
	
	/*
	ofEnableAlphaBlending();
	ofBackground(0,0,0);	
	glEnable (GL_MULTISAMPLE_ARB);
    glHint (GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST);
	
	setupCalled = true;	*/
}
/*
void testApp::setReferenceToOtherWindow( CustomGLViewDelegate* delegate, int i )
{
		
}
*/

//--------------------------------------------------------------
void testApp::update()
{
	float mousex = (float)mouseX/ofGetWidth();
	float mousey = (float)mouseY/ofGetHeight();
}

//--------------------------------------------------------------
void testApp::draw(){
	fps = ofGetFrameRate();
}


//--------------------------------------------------------------
void testApp::keyPressed(int key){
	if(key == 'f'){
		ofToggleFullscreen();
	}
	if(key == 'c'){
		//getPlugin<Cameras*>(pluginController)->vidGrabber->videoSettings();
	}
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
	
}

//------------- -------------------------------------------------
void testApp::mouseMoved(int x, int y ){
	
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
	
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
	
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
	
}

