//
//  GRAxes.h
//  GraphKitDemo
//
//  Created by Dave Jewell on 10/11/2008.
//  Copyright 2008 Cocoa Secrets. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GRChartView;

@interface GRAxes : NSObject <NSCoding, NSCopying>
{
	struct _NSRect _canvasRect;	// 4 = 0x4
	struct _NSRect _plotRect;	// 20 = 0x14
	NSMutableDictionary *_axesProperties;	// 36 = 0x24
	NSMutableDictionary *_subTitleTextAttributes;	// 40 = 0x28
	id _owner;	// 44 = 0x2c
	id _delegate;	// 48 = 0x30
	GRChartView *_chart;	// 52 = 0x34
	id _identifier;	// 56 = 0x38
	BOOL _needsLayout;	// 60 = 0x3c
	struct {
		struct _NSRect rect;
		struct _NSSize sz;
		struct _NSRect * prect;
		NSArray * arr;
		NSMutableDictionary * md;
		char ch;
	} *_extraData;	// 64 = 0x40
	unsigned int _reserved1;	// 68 = 0x44
	unsigned int _reserved2;	// 72 = 0x48
	unsigned int _reserved3;	// 76 = 0x4c
}

+ (void)initialize;	// IMP=0x4d58ac7c
+ (id)defaultProperties;	// IMP=0x4d58b6b8
+ (id)defaultPropertyForKey:(id)fp8;	// IMP=0x4d58b73c
+ (void)setDefaultProperty:(id)fp8 forKey:(id)fp12;	// IMP=0x4d58b78c
+ (void)setDefaultProperties:(id)fp8;	// IMP=0x4d58b8d8
+ (BOOL)accessInstanceVariablesDirectly;	// IMP=0x4d58c444
- (void)_setOwner:(id)fp8;	// IMP=0x4d58b970
- (id)initWithOwner:(id)fp8;	// IMP=0x4d58bad4
- (void)dealloc;	// IMP=0x4d58bc20
- (void)finalize;	// IMP=0x4d58bcf8
- (void)encodeWithCoder:(id)fp8;	// IMP=0x4d58bd68
- (id)initWithCoder:(id)fp8;	// IMP=0x4d58bf00
- (id)copyWithZone:(struct _NSZone *)fp8;	// IMP=0x4d58c1b0
- (id)owner;	// IMP=0x4d58c30c
- (id)chart;	// IMP=0x4d58c314
- (void)setDelegate:(id)fp8;	// IMP=0x4d58c31c
- (id)delegate;	// IMP=0x4d58c3d8
- (void)setIdentifier:(id)fp8;	// IMP=0x4d58c3e0
- (id)identifier;	// IMP=0x4d58c43c
- (id)_literalPropertyForKey:(id)fp8;	// IMP=0x4d58c44c
- (id)propertyForKey:(id)fp8;	// IMP=0x4d58c45c
- (id)valueForUndefinedKey:(id)fp8;	// IMP=0x4d58c4c4
- (void)didSetProperty:(id)fp8 forKey:(id)fp12 replacingOldValue:(id)fp16 andShouldReload:(char *)fp20 andRelayout:(char *)fp24 andRedisplay:(char *)fp28;	// IMP=0x4d58c4d0
- (void)chart:(id)fp8 propertyChangedForKey:(id)fp12 from:(id)fp16 to:(id)fp20;	// IMP=0x4d58ccd0
- (void)dataSet:(id)fp8 propertyChangedForKey:(id)fp12 from:(id)fp16 to:(id)fp20;	// IMP=0x4d58cea8
- (void)setProperty:(id)fp8 forKey:(id)fp12;	// IMP=0x4d58d02c
- (void)setValue:(id)fp8 forUndefinedKey:(id)fp12;	// IMP=0x4d58d290
- (id)properties;	// IMP=0x4d58d29c
- (void)setProperties:(id)fp8;	// IMP=0x4d58d2dc
- (void)_updateTextProperties;	// IMP=0x4d58d2ec
- (void)setCanvasRect:(struct _NSRect)fp8;	// IMP=0x4d58d42c
- (struct _NSRect)canvasRect;	// IMP=0x4d58d5b8
- (struct _NSRect)plotRect;	// IMP=0x4d58d5dc
- (void)setPlotRect:(struct _NSRect)fp8;	// IMP=0x4d590530
- (id)legendLabels;	// IMP=0x4d58d600
- (struct _NSRect)legendRect;	// IMP=0x4d58ec88
- (BOOL)computeLayout;	// IMP=0x4d58d614
- (void)setNeedsLayout:(BOOL)fp8;	// IMP=0x4d58dd2c
- (BOOL)needsLayout;	// IMP=0x4d58dd8c
- (BOOL)_supportsCopyOnScroll;	// IMP=0x4d58dd98
- (void)drawLegendSampleInRect:(struct _NSRect)fp8 forDataSet:(unsigned int)fp24 withHighlight:(BOOL)fp28;	// IMP=0x4d58dda0
- (void)drawLegendRect:(struct _NSRect)fp8;	// IMP=0x4d5907f8
- (void)drawBackgroundInRect:(struct _NSRect)fp8;	// IMP=0x4d58ddb4
- (void)drawGridRect:(struct _NSRect)fp8;	// IMP=0x4d58e0c0
- (void)drawAxesRect:(struct _NSRect)fp8;	// IMP=0x4d58e130
- (BOOL)_zoomInRect:(struct _NSRect)fp8;	// IMP=0x4d58e490
- (BOOL)_zoomOut;	// IMP=0x4d58e4a8
- (BOOL)_autoscale;	// IMP=0x4d58e4b0
- (BOOL)deselectAllPoints;	// IMP=0x4d58e4b8
- (BOOL)selectPoint:(struct _NSPoint)fp8 byExtendingSelection:(BOOL)fp16;	// IMP=0x4d58e5d0
- (BOOL)clickPoint:(struct _NSPoint)fp8;	// IMP=0x4d58e5e0
- (double)_pixelValueForAxis:(unsigned short)fp8;	// IMP=0x4d58e5f0
- (double)xPixelValue;	// IMP=0x4d58e78c
- (double)yPixelValue;	// IMP=0x4d58e79c
- (double)_valueAtPoint:(struct _NSPoint)fp8 axis:(unsigned short)fp16;	// IMP=0x4d58e7ac
- (double)xValueAtPoint:(struct _NSPoint)fp8;	// IMP=0x4d58e9c8
- (double)yValueAtPoint:(struct _NSPoint)fp8;	// IMP=0x4d58e9e0
- (struct _NSPoint)locationForXValue:(double)fp8 yValue:(double)fp16;	// IMP=0x4d58e9f8

@end
