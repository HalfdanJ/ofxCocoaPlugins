

#import "OutputViewStats.h"
#import "PluginOpenGLView.h"
#define numPoints 50

@implementation OutputViewStats
@synthesize fps;

-(id) initWithFrame:(NSRect)frameRect outputView:(PluginOpenGLView*)view{
	if([super initWithFrame:frameRect]){
		
		historyData = [[NSMutableArray arrayWithCapacity:numPoints] retain];
		int i;
		for(i=0;i<numPoints;i++){
			[historyData addObject:[NSNumber numberWithInt:0]];
		}
		
		NSTextField * title = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width-40, 20)];
		[title setAutoresizingMask:NSViewWidthSizable];
		[title setEditable:NO];
		[title setBordered:NO];
		[title setDrawsBackground:NO];
		[title setTextColor:[NSColor whiteColor]];
		[title setStringValue:[NSString stringWithFormat:@"Output %i:",[view viewNumber]]];
		
		NSTextField * fpsField = [[NSTextField alloc] initWithFrame:NSMakeRect(65, 0, frameRect.size.width-100, 20)];
		[fpsField setAutoresizingMask:NSViewWidthSizable];
		[fpsField setEditable:NO];
		[fpsField setBordered:NO];
		[fpsField setDrawsBackground:NO];
		[fpsField setTextColor:[[NSColor whiteColor] colorWithAlphaComponent:0.7]];
		[fpsField setStringValue:@"60.0" ];
		[fpsField bind:@"value" toObject:self withKeyPath:@"fps" options:nil];
		
		NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:1];
		[fpsField setFormatter:formatter];
		
		[self addSubview:title];
		[self addSubview:fpsField];
		
		
	/*	graphView = [[GRChartView alloc] initWithFrame:NSMakeRect(100, 3,  100, 20)];
		[graphView setDelegate:self];
		[graphView setDataSource:self];
		GRAxes * axes = [graphView axes];
		
		
		[graphView setProperty:[NSNumber numberWithInt:1] forKey:@"GRChartAllowClick"];
		[graphView setProperty:[NSNumber numberWithInt:1] forKey:@"GRChartAllowSelection"];
		
		[graphView setProperty:[NSNumber numberWithInt:1] forKey:@"GRChartPassMouseEventsThrough"];
		[graphView setProperty:[[NSColor whiteColor] colorWithAlphaComponent:0.2] forKey:@"GRChartBackgroundColor"];
		[graphView setProperty:@"GRChartBorder" forKey:@"GRChartBorderType"];
		[graphView setProperty:[NSNumber numberWithInt:0] forKey:@"GRDataSetDrawShadow"];
		[graphView setDefaultPlotColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedRed:135/255.0 green:147/255.0 blue:157/255.0 alpha:1.0],nil]];
		
		
		//	[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesDrawLegend"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawXAxis"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawXLabels"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawYAxis"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawYLabels"];	
		
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesBottomMargin"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesLeftMargin"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesTopMargin"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesRightMargin"];	
		
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawXMajorLines"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawPlotFrame"];	
		
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesDrawYMajorLines"];	
		//[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesFixedXPlotMax"];	
		//[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesFixedXPlotMin"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesLegendChartMargin"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesLegendEdgeMargin"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesLegendGutter"];	
		
		[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesFixedYPlotMax"];	
		[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesFixedYPlotMin"];	
		[axes setProperty:[NSNumber numberWithInt:80] forKey:@"GRAxesYPlotMax"];	
		[axes setProperty:[NSNumber numberWithInt:0] forKey:@"GRAxesYPlotMin"];
		
        GRLineDataSet * dataSet = [[GRColumnDataSet  alloc] initWithOwnerChart: graphView] ;
		[dataSet setProperty: [NSNumber numberWithInt: 0] forKey: GRDataSetDrawPlotLine];
		[dataSet setProperty: [NSNumber numberWithInt: 0] forKey: @"GRDataSetDrawMarkers"];
		[dataSet setProperty: [NSNumber numberWithInt: 1] forKey: @"GRDataSetCategoryGapFraction"];
		[graphView addDataSet: dataSet loadData: YES];
		
		
		
		
		[dataSet release];
		
		
		[self addSubview:graphView];
     */
		
	}
	return self;
}

/*
- (NSInteger) chart: (GRChartView *) chartView numberOfElementsForDataSet: (GRDataSet *) dataSet
{
	return [historyData count];
}


- (double) chart: (GRChartView *) chartView yValueForDataSet: (GRDataSet *) dataSet element: (NSInteger) element
{
	return [[historyData  objectAtIndex:element]  doubleValue];
}



- (double) chart: (GRChartView *) chartView xValueForDataSet: (GRDataSet *) dataSet element: (NSInteger) element
{
	return element;
}
*/
-(void)reloadGraph{
//	dispatch_async(dispatch_get_main_queue(), ^{			
	//[graphView reloadData];
//	});
}

-(void) addHistory:(NSNumber*)_fps{
	if(_fps != nil){
		dispatch_async(dispatch_get_main_queue(), ^{			
			[historyData removeObjectAtIndex:0];
			[historyData addObject:_fps];
		});
	}
}
@end
