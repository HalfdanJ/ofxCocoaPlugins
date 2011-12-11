#pragma once
#include "ofMain.h"
#include "ofVectorMath.h"

void of2DArrow(ofVec2f begin, ofVec2f end, float headSize){
    // Compute the vector along the arrow direction
    ofVec2f v = begin-end;
    v.normalize();
    
    // Compute two perpendicular vectors to v
    ofVec2f vPerp1 = ofVec2f(-v.y, v.x);
    ofVec2f vPerp2 = ofVec2f(v.y, -v.x);
    
    // Compute two half-way vectors
    ofVec2f v1 = (v + vPerp1).normalized();
    ofVec2f v2 = (v + vPerp2).normalized();
    
    glBegin(GL_TRIANGLES);

    ofVec2f p1 = end + headSize * v1;
    ofVec2f p2 = end + headSize * v2;

    glVertex2f(end.x,end.y);
    glVertex2f(p1.x,p1.y);
    glVertex2f(p2.x,p2.y);
    glEnd();
    
    glBegin(GL_LINES);
    glVertex2f(begin.x, begin.y);
    glVertex2f(end.x, end.y);
    glEnd();
}