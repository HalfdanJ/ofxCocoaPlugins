#pragma once
#include "ofMain.h"
#include "ofxVectorMath.h"

void of2DArrow(ofPoint begin, ofPoint end, int headSize){
    // Compute the vector along the arrow direction
    ofxVec2f v = begin-end;
    v.normalize();
    
    // Compute two perpendicular vectors to v
    ofxVec2f vPerp1 = ofxVec2f(-v.y, v.x);
    ofxVec2f vPerp2 = ofxVec2f(v.y, -v.x);
    
    // Compute two half-way vectors
    ofxVec2f v1 = (v + vPerp1).normalized();
    ofxVec2f v2 = (v + vPerp2).normalized();
    
    glBegin(GL_TRIANGLES);

    ofxPoint2f p1 = end + headSize * v1;
    ofxPoint2f p2 = end + headSize * v2;

    glVertex2f(end.x,end.y);
    glVertex2f(p1.x,p1.y);
    glVertex2f(p2.x,p2.y);
    glEnd();
    
    glBegin(GL_LINES);
    glVertex2f(begin.x, begin.y);
    glVertex2f(end.x, end.y);
    glEnd();
}