#pragma once
#include "ofMain.h"
#include "coordWarp.h"

class TextureGrid {
    
    
public:
    
    
    coordWarping * warper1, *warper2;
    void drawTextureGrid(ofTexture * tex, ofxPoint2f * polygon, ofxPoint2f * textureCorners, int gridSize){
        ofxPoint2f ref[4];
        ref[0] = ofxPoint2f(0.0,0.0);
        ref[1] = ofxPoint2f(1.0,0.0);
        ref[2] = ofxPoint2f(1.0,1.0);
        ref[3] = ofxPoint2f(0.0,1.0);
        
        warper1 = new coordWarping();
        warper1->calculateMatrix(ref, polygon);
        
        warper2 = new coordWarping();
        warper2->calculateMatrix(ref, textureCorners);
        
       
        tex->bind();
        float step = 1.0/gridSize;
        for(float x=0 ; x<1 ; x+=step){
            glBegin(GL_QUAD_STRIP);
            for(float y=0 ; y<=1 ; y+=step){   
                ofPoint p1 = warper1->transform(x, y);
                ofPoint p2 = warper1->transform(x+step, y);

                ofPoint c1 = warper2->transform(x, y);
                ofPoint c2 = warper2->transform(x+step, y);

                glTexCoord2d(c1.x, c1.y);
                glVertex2d(p1.x, p1.y);
                glTexCoord2d(c2.x, c2.y);
                glVertex2d(p2.x, p2.y);
            }
            glEnd();
        }
        tex->unbind();
        delete warper1;
        delete warper2;        
       
    }
    
};