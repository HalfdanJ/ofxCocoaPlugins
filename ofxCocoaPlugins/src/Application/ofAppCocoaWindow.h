#pragma once

#include "ofAppBaseWindow.h"
#include "ofBaseApp.h"
#include "ofAppRunner.h"


class ofAppCocoaWindow : public ofAppBaseWindow{
public:
	
	ofAppCocoaWindow();
	virtual ~ofAppCocoaWindow(){};
		
	virtual void		setupOpenGL(int w, int h, int screenMode);
	
	virtual void		setWindowPosition(int x, int y);
	virtual void		setWindowShape(int w, int h);
	
	virtual int			getFrameNum();
	virtual float		getFrameRate();
	
	virtual ofPoint		getWindowPosition();
	virtual ofPoint		getWindowSize();
	virtual ofPoint		getScreenSize();
    virtual int         getWidth();
    virtual int         getHeight();

	virtual void		setFrameRate(float targetRate);
	
	virtual void		keyPressed(int key);
	virtual void		mousePressed(float x, float y, int button);
	virtual void		mouseMoved(float x, float y);
	virtual void		mouseDragged(float x, float y, int button);
	virtual void		mouseReleased(int button);
	
	// cache these, they're not gonne change during duration of app
	ofPoint				screenSize;
	ofPoint				windowSize;
	ofPoint				windowPos;
	
	int windowW, windowH;
	int windowX, windowY;
	
	bool			bNewScreenSize;
	bool			bNewScreenPosition;
	bool			bNewWindowString;
	

	int				requestedWidth;
	int				requestedHeight;

	int				requestedX;
	int				requestedY;
	
	int				windowMode;
	bool			bNewScreenMode;
	float			timeNow, timeThen, fps;
	int				nFramesForFPS;
	int				nFrameCount;
	int				buttonInUse;
	bool			bEnableSetupScreen;

	bool			bFrameRateSet;
	int 			millisForFrame;
	int 			prevMillis;
	int 			diffMillis;

	double 			frameRate;
	double			frameRateGoal;
	int 			nonFullScreenX;
	int 			nonFullScreenY;
};



