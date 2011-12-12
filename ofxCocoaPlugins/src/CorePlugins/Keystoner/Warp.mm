#include "Warp.h"

Warp::Warp()
{
	// CORNERS
//	SetWindowSize(1024, 768));
	SetWindowSize(1.0,1.0);

	corners[0].set(0,0);
	corners[1].set(1,0);
	corners[2].set(1,1);
	corners[3].set(0,1);


	// MATRIX STUFF
	cv_translate_3x3 = cvCreateMat(3, 3, CV_32FC1);
	cv_srcmatrix_4x2 = cvCreateMat(4, 2, CV_32FC1);
	cv_dstmatrix_4x2 = cvCreateMat(4, 2, CV_32FC1);
}

Warp::~Warp()
{
	cvReleaseMat(&cv_translate_3x3);
	cvReleaseMat(&cv_srcmatrix_4x2);
	cvReleaseMat(&cv_dstmatrix_4x2);
    
}

void
Warp::SetCorner(int i, float x, float y)
{
	if (i > 3 || i < 0)
		return;

	corners[i].set(x, y);
}

void
Warp::SetClosestCorner(float x, float y)
{
	int iCorner = GetClosestCorner(x, y);
	SetCorner(iCorner, x, y);
}

int
Warp::GetClosestCorner(float x, float y)
{
	float fDistMin = 1000;
	float fDist;
	int iCorner = 0;
	ofVec2f vPos(x, y);

	for (int i = 0; i < 4; ++i)
	{
		fDist = (vPos.distance(corners[i]));
		if (fDist < fDistMin)
		{
			fDistMin = fDist;
			iCorner = i;
		}
	}

	return iCorner;
}

void
Warp::SetWindowSize(float _w, float _h)
{
	w = _w;
	h = _h;
}

void
Warp::DrawCorners()
{
	glPushMatrix();
		glColor4f(1,0,1,1);
		glBegin(GL_LINE_LOOP);
			for (int i = 0; i < 4; ++i)
				glVertex3f(corners[i].x * w, corners[i].y * h, 0);
		glEnd();
	glPopMatrix();
}

float*
Warp::MatrixCalculate()
{	
	cvsrc[0].x = 0;
	cvsrc[0].y = 0;
	cvsrc[1].x = w;
	cvsrc[1].y = 0;
	cvsrc[2].x = w;
	cvsrc[2].y = h;
	cvsrc[3].x = 0;
	cvsrc[3].y = h;

	for(int i = 0; i < 4; i++){
		
		cvdst[i].x = corners[i].x * w;
		cvdst[i].y = corners[i].y * h;
	}

	cvSetData( cv_srcmatrix_4x2, cvsrc, sizeof(CvPoint2D32f));
	cvSetData( cv_dstmatrix_4x2, cvdst, sizeof(CvPoint2D32f));
	
	cvFindHomography(cv_srcmatrix_4x2, cv_dstmatrix_4x2, cv_translate_3x3);
	
	float *matrix = cv_translate_3x3->data.fl;
	
    cout << "--------------------------------------------" << endl << endl;
    
    cout << matrix[0] << ", \t" << matrix[1] << ", \t" << matrix[2] << endl;
    cout << matrix[3] << ", \t" << matrix[4] << ", \t" << matrix[5] << endl;
    cout << matrix[6] << ", \t" << matrix[7] << ", \t" << matrix[8] << endl << endl;
    
    cout << "--------------------------------------------" << endl << endl;

    
    //we need to copy these values
    //from the 3x3 2D openCV matrix which is row ordered
    //
    // ie:   [0][1][2] x
    //       [3][4][5] y
    //       [6][7][8] w
    
    //to openGL's 4x4 3D column ordered matrix
    //        x  y  z  w   
    // ie:   [0][3][ ][6]
    //       [1][4][ ][7]
    //               [ ][ ][ ][ ]
    //       [2][5][ ][9]
    //       
    
    gl_matrix_4x4[0]		= matrix[0];
	gl_matrix_4x4[4]		= matrix[1];
	gl_matrix_4x4[12]		= matrix[2];

	gl_matrix_4x4[1]		= matrix[3];
	gl_matrix_4x4[5]		= matrix[4];
	gl_matrix_4x4[13]		= matrix[5];
	
    gl_matrix_4x4[3]		= matrix[6];
    gl_matrix_4x4[7]		= matrix[7];
    gl_matrix_4x4[15]		= matrix[8];

    
    gl_matrix_4x4[2]		= 0;
    gl_matrix_4x4[6]		= 0;
    gl_matrix_4x4[8]		= 0;
    gl_matrix_4x4[9]		= 0;
    gl_matrix_4x4[10]		= 1;
    gl_matrix_4x4[11]		= 0;
    gl_matrix_4x4[14]		= 0;

    cout << gl_matrix_4x4[0] << ", \t" << gl_matrix_4x4[1] << ", \t" << gl_matrix_4x4[2] << ", \t" << gl_matrix_4x4[3] << endl;
    cout << gl_matrix_4x4[4] << ", \t" << gl_matrix_4x4[5] << ", \t" << gl_matrix_4x4[6] << ", \t" << gl_matrix_4x4[7] << endl;
    cout << gl_matrix_4x4[8] << ", \t" << gl_matrix_4x4[9] << ", \t" << gl_matrix_4x4[10] << ", \t" << gl_matrix_4x4[11] << endl;
    cout << gl_matrix_4x4[12] << ", \t" << gl_matrix_4x4[13] << ", \t" << gl_matrix_4x4[14] << ", \t" << gl_matrix_4x4[15] << endl << endl;
    
    cout << "============================================" << endl<< endl;
    
	return gl_matrix_4x4;
}

void Warp::MatrixMultiply()
{
	glMultMatrixf(gl_matrix_4x4);
}


ofVec2f	Warp::convertPoint(ofVec2f point){
	double pts[] = {point.x,point.y};
	CvMat foundRect = cvMat(1, 1, CV_64FC2, pts);		
	
	cvPerspectiveTransform(&foundRect, &foundRect, cv_translate_3x3);
	
	float *matrix = foundRect.data.fl;
	cout<<"In: "<<point.x<<", "<<point.y<<"  Out: "<<matrix[0]<<","<<matrix[1]<<endl;
    return ofVec2f(matrix[0],matrix[1]);
}