/*
|==============================================================================
| Copyright (C) 2004-2011 Prosilica.  All Rights Reserved.
|
| Redistribution of this header file, in original or modified form, without
| prior written consent of Prosilica is prohibited.
|
|==============================================================================
|
| File:			ImageLib.h
|
| Project/lib:	PvAPI
|
| Target:		Win32, Linux, QNX
|
| Description:	Provide a function to save a Frame in a TIFF image file.
|
| Notes:		
|
|
|	LIBTIFF Use and Copyright
|	~~~~~~~~~~~~~~~~~~~~~~~~~
|
|	Copyright (c) 1988-1997 Sam Leffler
|	Copyright (c) 1991-1997 Silicon Graphics, Inc.
|
|	Permission to use, copy, modify, distribute, and sell this software and 
|	its documentation for any purpose is hereby granted without fee, provided
|	that (i) the above copyright notices and this permission notice appear in
|	all copies of the software and related documentation, and (ii) the names of
|	Sam Leffler and Silicon Graphics may not be used in any advertising or
|	publicity relating to the software without the specific, prior written
|	permission of Sam Leffler and Silicon Graphics.
|
|	THE SOFTWARE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND, 
|	EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY 
|	WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  
|
|	IN NO EVENT SHALL SAM LEFFLER OR SILICON GRAPHICS BE LIABLE FOR
|	ANY SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND,
|	OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
|	WHETHER OR NOT ADVISED OF THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF 
|	LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE 
|	OF THIS SOFTWARE.
|
|==============================================================================
| dd/mon/yy  Author		Notes
|------------------------------------------------------------------------------
| 01/01/04	 JLV		Original.
| 24/03/11   AKA		Updated to LibTIFF 3.9.4. Now builds with VC++ 2008, 2010.
|==============================================================================
*/

#ifndef IMAGELIB_H_INCLUDE
#define IMAGELIB_H_INCLUDE

//===== INCLUDE FILES =========================================================

#include <PvApi.h>

#ifdef __cplusplus
extern "C" {
#endif

//===== FUNCTION PROTOTYPES ===================================================

bool ImageWriteTiff(const char* filename, const tPvFrame* pFrame);

}


#endif // IMAGELIB_H_INCLUDE

