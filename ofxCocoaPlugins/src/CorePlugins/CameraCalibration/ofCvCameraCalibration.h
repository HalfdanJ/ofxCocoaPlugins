/*
 *  camera calibration
 *  stefanix - helloworld@stefnix.net
 */


#ifndef _OF_CV_CAMERACALIBRATION
#define _OF_CV_CAMERACALIBRATION

#include <iostream>
#include <vector>
#include "ofMain.h"
#include "ofxCvMain.h"


class ofCvCameraCalibration {
public:
    
    CvSize csize;
    
    //input
    vector<IplImage*> colorImages;    
    int nCornersX;
    int nCornersY;
    vector<ofVec2f> screenPoints;    //nCornersX*nCornersY per image
    vector<ofVec3f> worldPoints;     //nCornersX*nCornersY per image
    //output
    vector<IplImage*> undistortedImg;     
    ofVec4f  distortionCoeffs;            //1 per camera
    // radial, tangential
    //[k1, k2, c1, c2]
    ofMatrix3x3  camIntrinsics;           //1 per camera
    // focal, center
    //[fx 0 cx; 0 fy cy; 0 0 1]    
    vector<ofVec3f>  transVectors;        //1 per image
    vector<ofMatrix3x3>  rotMatrices;     //1 per image  
    
    
    void allocate( CvSize _csize, int _nCornersX=7, int _nCornersY=7 );
    
    bool addImage( IplImage* img );
    void calibrate();
    void undistort();    
    
    ofPoint undistortPoint(float _x, float _y);
    ofPoint distortPoint(float _x, float _y);
    
    bool findCorners( const IplImage* bw,
                     vector<ofVec2f>& points
                     ) const;
    void calibrateCamera( const int                   nImages,
                         const vector<ofVec2f>&    _screenPoints,
                         const vector<ofVec3f>&    _worldPoints,
                         ofVec4f&                    _distortionCoeffs,
                         ofMatrix3x3&                _camIntrinsics,
                         vector<ofVec3f>&            _transVectors,
                         vector<ofMatrix3x3>&        _rotMatrices
                         ) const;
    void drawCircles( IplImage* img, vector<ofVec2f>& points );
    CvPoint2D32f* ConvertWorldToPixel( CvPoint3D32f *pts3d, int numImages, 
                                      int *numPts, CvMatr32f cam, 
                                      CvVect32f t, CvMatr32f r);    
    void printIntrinsics( const CvVect32f& distortion, 
                         const CvMatr32f& camera_matrix ) const;
    void PrintIntrinsics( const CvVect32f& distortion, 
                         const CvMatr32f& camera_matrix ) const;
    void PrintMatrix( const CvMatr32f& matrix, 
                     unsigned int rows, unsigned int cols ) const;
    
};


#endif