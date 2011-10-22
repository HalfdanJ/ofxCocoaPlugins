#ifndef WARP_H
#define WARP_H

#include "ofxOpenCv.h"
#include "ofGraphics.h"
#include "ofVectorMath.h"


class Warp
{
public:
	Warp();
	~Warp();

	void					SetCorner(int i, float x, float y);
	void					SetClosestCorner(float x, float y);
	int						GetClosestCorner(float x, float y);
	void					SetWindowSize(float _w, float _h);
	void					DrawCorners();

	float*					MatrixCalculate();
	void					MatrixMultiply();
	
	ofVec2f				convertPoint(ofVec2f point);
	ofVec2f			corners[4];

private:
	// CORNERS
	float					w;
	float					h;

	CvPoint2D32f			cvsrc[4];
	CvPoint2D32f			cvdst[4];

	// MATRIX STUFF
	GLfloat					gl_matrix_4x4[16];
	CvMat*					cv_translate_3x3;
	CvMat*					cv_srcmatrix_4x2;
	CvMat*					cv_dstmatrix_4x2;
};

#endif