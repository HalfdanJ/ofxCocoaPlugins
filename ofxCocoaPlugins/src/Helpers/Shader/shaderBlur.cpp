/*
 *  shaderBlur.cpp
 *  openFrameworks
 *
 *  Created by theo on 17/10/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "shaderBlur.h"

//--------------------------------------------------------------
void shaderBlur::setup(int fboW, int fboH){	
	
	ofBackground(255,255,255);	
	ofSetVerticalSync(true);
	
	fbo1.allocate(fboW, fboH);
	fbo2.allocate(fboW, fboH);
  //  fbo1.clear(0,0,0,1);
  //  fbo2.clear(0,0,0,1);
	
	shaderH.setup("shaders/simpleBlurHorizontal");
	shaderV.setup("shaders/simpleBlurVertical");

	noPasses = 1;
	blurDistance = 2.0;
}

//--------------------------------------------------------------
void shaderBlur::beginRender(){
 
	fbo1.swapIn();
   fbo1.setupScreenForThem();
	fbo1.clear(0,0,0,1);
}

//--------------------------------------------------------------
void shaderBlur::endRender(){
	fbo1.swapOut();
    fbo1.setupScreenForMe();
    
    ofxFBOTexture * src, * dst;
	src = &fbo1;
	dst = &fbo2;
    
	if( 1 ){
        
		for(int i = 0; i < noPasses; i++){
			//float blurPer =  blurDistance * ofMap(i, 0, noPasses, 1.0/noPasses, 1.0);
			
			//first the horizontal shader 
			shaderH.begin();
			shaderH.setUniform("blurAmnt", blurDistance);
			
			dst->swapIn();
            dst->setupScreenForThem();
            
            
			src->draw(0, 0,1,1);
			dst->swapOut();
            dst->setupScreenForMe();
            
			shaderH.end();
			
			//now the vertical shader
			shaderV.begin();	
			shaderV.setUniform("blurAmnt", blurDistance);
            
			src->swapIn();
            dst->setupScreenForThem();
            
			dst->draw(0,0,1,1);
			src->swapOut();
            dst->setupScreenForMe();
			shaderV.end();
			
            //			ofxFBOTexture  * tmp = src;
            //			src = dst;
            //			dst = tmp;
		}		
		
	}
	
}

//--------------------------------------------------------------
void shaderBlur::setBlurParams(int numPasses, float blurDist){
	noPasses		= ofClamp(numPasses, 1, 100000);
	blurDistance	= blurDist;
}

//--------------------------------------------------------------
void shaderBlur::draw(float x, float y, float w, float h, bool useShader){
	
	
//	ofEnableAlphaBlending();	
//	ofSetColor(255, 255, 255, 255);
	fbo1.draw(x, y, w, h);	

}



