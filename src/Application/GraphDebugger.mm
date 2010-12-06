//
//  graphDebugger.m
//  simpleExample
//
//  Created by Jonas Jongejan on 09/03/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "GraphDebugger.h"


GraphDebugger * globalGraphDebugger;




@implementation GraphDebugger


@synthesize displayedData;
@synthesize properties;


- (Class) dataSetClass
{
	// Available: GRXYDataSet, GRPieDataSet, GRAreaDataSet, GRLineDataSet, GRColumnDataSet
	return [GRLineDataSet class];
}


-(void) awakeFromNib{
	//
	//Init
	//
	lastRefresh = 0;
	changeRefreshrateTo = -1;
	startDate = [[NSDate alloc] init];
	globalGraphDebugger = self;
	properties = [[NSMutableArray array] retain];
	data = [[NSMutableArray array] retain];
	displayedData = [[NSMutableArray array] retain];
	newData = [[NSMutableArray array] retain];
	lastRefreshProperties = [[NSMutableDictionary dictionary] retain];
	newRefreshProperties = [[NSMutableDictionary dictionary] retain];
	
	//
	//Bindings
	//
	
	[self bind:@"xRangeMin" toObject:hostView withKeyPath:@"xRangeMin" options:nil];
	[self bind:@"xRangeMax" toObject:hostView withKeyPath:@"xRangeMax" options:nil];
	
	[hostView bind:@"xMin" toObject:self withKeyPath:@"xMin" options:nil];
	[hostView bind:@"xMax" toObject:self withKeyPath:@"xMax" options:nil];
	
	
	//
	//Timer
	//
/*	refreshTimer =  [NSTimer timerWithTimeInterval:0.1   //a 1ms time interval
											target:self
										  selector:@selector(refresh)
										  userInfo:nil
										   repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:refreshTimer 
								 forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:refreshTimer 
								 forMode:NSEventTrackingRunLoopMode];*/
	
	//
	//GraphKit 	
	//
	GRAxes * axes = [graphView axes];
	
	
	[graphView setProperty:[NSNumber numberWithInt:1] forKey:@"GRChartAllowClick"];
	[graphView setProperty:[NSNumber numberWithInt:1] forKey:@"GRChartAllowSelection"];
	
	[graphView setProperty:[NSNumber numberWithInt:1] forKey:@"GRChartPassMouseEventsThrough"];
	[graphView setProperty:[NSColor whiteColor] forKey:@"GRChartBackgroundColor"];
	[graphView setProperty:@"GRChartBorder" forKey:@"GRChartBorderType"];
	[graphView setProperty:[NSNumber numberWithInt:0] forKey:@"GRDataSetDrawShadow"];
	
	//	[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesDrawLegend"];	
	[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesDrawXMajorLines"];	
	[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesDrawYMajorLines"];	
	//[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesFixedXPlotMax"];	
	//[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesFixedXPlotMin"];	
	[axes setProperty:[NSNumber numberWithInt:1] forKey:@"GRAxesLegendChartMargin"];	
	[axes setProperty:[NSNumber numberWithInt:5] forKey:@"GRAxesLegendEdgeMargin"];	
	[axes setProperty:[NSNumber numberWithInt:3] forKey:@"GRAxesLegendGutter"];	
	
	//	NSLog(@"Properties %@",[axes properties]);
	
	//NSLog(@"Default props: %@",[GRLineDataSet defaultProperties]);
	
}



- (NSInteger) chart: (GRChartView *) chartView numberOfElementsForDataSet: (GRDataSet *) dataSet
{
	if([displayedData count] == 0)
		return 0;
	
	int index = [[graphView dataSets] indexOfObject:dataSet];
	return [[displayedData objectAtIndex:index]  count];
}


- (double) chart: (GRChartView *) chartView yValueForDataSet: (GRDataSet *) dataSet element: (NSInteger) element
{
	int index = [[graphView dataSets] indexOfObject:dataSet];
	return [[[[displayedData objectAtIndex:index]  objectAtIndex:element] valueForKey:@"y"] doubleValue];
}



- (double) chart: (GRChartView *) chartView xValueForDataSet: (GRDataSet *) dataSet element: (NSInteger) element
{
	int index = [[graphView dataSets] indexOfObject:dataSet];
	
	return [[[[displayedData objectAtIndex:index] objectAtIndex:element] valueForKey:@"x"] doubleValue];
	
}


-(void) refreshDiplayedData {
	BOOL isVisible = [[hostView window] isVisible]; 
	NSTimeInterval t = -[startDate timeIntervalSinceNow];
	//if(isVisible){
	[self willChangeData];
	//}
	NSMutableArray * dispArray;
	NSMutableArray * dataArray;
	
	BOOL addNewRecords = NO;
	
	if([[newRefreshProperties valueForKey:@"XRangeMax"] floatValue] == [[self xMax] floatValue]){
		addNewRecords = YES;
	}		
	
	int i=0;	
	for(i=0;i<[data count];i++){
		BOOL remakeArray = NO;
		
		dispArray = [displayedData objectAtIndex:i];
		int dispEndBefore = [dispArray count] - 1;
		
		dataArray = [data objectAtIndex:i];
		dispArray = [displayedData objectAtIndex:i];
		NSMutableArray * insideArray = [newData objectAtIndex:i];
		
		//	[dataArray addObjectsFromArray:[newData objectAtIndex:i]];		
		//	[dispArray addObjectsFromArray:[newData objectAtIndex:i]];	
		if ([insideArray count] > 0) {			
			[dataArray addObject:[insideArray lastObject] ];
			if(addNewRecords)
				[dispArray addObject:[insideArray lastObject] ];
			[insideArray removeAllObjects];
		} else if([dataArray count] > 0) {
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[dataArray lastObject]];
			[dict setValue:[NSNumber numberWithDouble:t] forKey:@"x"];
			[dataArray addObject:dict];
			if(addNewRecords){
				[dispArray addObject:dict];				
			}
			
		}
		
		
		
		if([[newRefreshProperties valueForKey:@"XRangeMin"] floatValue] > [[lastRefreshProperties valueForKey:@"XRangeMin"] floatValue]){
			remakeArray = YES;
		}		
		if([[newRefreshProperties valueForKey:@"XRangeMin"] floatValue] < [[lastRefreshProperties valueForKey:@"XRangeMin"] floatValue]){
			remakeArray = YES;
		}
		
		if([[newRefreshProperties valueForKey:@"XRangeMax"] floatValue] > [[lastRefreshProperties valueForKey:@"XRangeMax"] floatValue]){
			remakeArray = YES;
		}		
		if([[newRefreshProperties valueForKey:@"XRangeMax"] floatValue] < [[lastRefreshProperties valueForKey:@"XRangeMax"] floatValue]){
			remakeArray = YES;
		}
		
		
		if(remakeArray){
			[dispArray removeAllObjects];
			
			NSMutableDictionary * dict;
			for(dict in dataArray){		
				if([[dict valueForKey:@"x"] floatValue] >= [[newRefreshProperties valueForKey:@"XRangeMin"] floatValue] && 
				   [[dict valueForKey:@"x"] floatValue] <= [[newRefreshProperties valueForKey:@"XRangeMax"] floatValue]){
					[dispArray addObject:dict];
				}				
			}
		}
		
		if(isVisible){		
			if(remakeArray){
				[[[graphView dataSets] objectAtIndex:i] reloadData];
			} else if(addNewRecords){
				[[[graphView dataSets] objectAtIndex:i] reloadDataInRange:NSMakeRange(dispEndBefore, ([dispArray count]-1) - dispEndBefore)];
			}
		}	
		
	}
	//if(isVisible){
	[self didChangeData];
	//}
	lastRefresh = t;
	[lastRefreshProperties setDictionary:newRefreshProperties];
	
}


//Called periodicly by NSTimer runloop
-(void)refresh{
	if(changeRefreshrateTo != -1){
		[refreshTimer invalidate];			
		/*refreshTimer =  [NSTimer timerWithTimeInterval:changeRefreshrateTo 
												target:self
											  selector:@selector(refresh)
											  userInfo:nil
											   repeats:YES];
		
		[[NSRunLoop currentRunLoop] addTimer:refreshTimer 
									 forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:refreshTimer 
									 forMode:NSEventTrackingRunLoopMode];*/
		changeRefreshrateTo = -1;
	}
	
	[self refreshDiplayedData];
}


-(void) setXRangeMin:(NSNumber*)n{
	//GRAxes * axes = [graphView axes];
	//[axes setProperty:n forKey:@"GRAxesXPlotMin"];	
	[newRefreshProperties setValue:n forKey:@"XRangeMin"];	
}

-(NSNumber *) xRangeMin{
	return [NSNumber numberWithInt:0];	
}

-(void) setXRangeMax:(NSNumber*)n{
	//GRAxes * axes = [graphView axes];
	//[axes setProperty:n forKey:@"GRAxesXPlotMax"];	
	[newRefreshProperties setValue:n forKey:@"XRangeMax"];	
}

-(NSNumber *) xRangeMax{
	return [NSNumber numberWithInt:1];	
}


-(NSNumber *) xMin{
	NSMutableDictionary * dict;
	double  min = 0;
	BOOL first = YES;
	NSMutableArray * arr;
	for(arr in data ){
		for(dict in arr){
			if(first || min  > [[dict objectForKey:@"x"] doubleValue]){
				min = [[dict objectForKey:@"x"]doubleValue];
			}
			first = NO;
		}
	}
	return [NSNumber numberWithDouble:min];
}

-(NSNumber *) xMax{
	NSMutableDictionary * dict;
	double  max = 1;
	BOOL first = YES;
	NSMutableArray * arr;
	for(arr in data ){
		for(dict in arr){
			if(first || max  < [[dict objectForKey:@"x"] doubleValue]){
				max = [[dict objectForKey:@"x"]doubleValue];
			}
			first = NO;
		}
	}
	return [NSNumber numberWithDouble:max];
}


-(void) willChangeData{
	[self willChangeValueForKey:@"yMin"];
	[self willChangeValueForKey:@"yMax"];
	[self willChangeValueForKey:@"xMin"];
	[self willChangeValueForKey:@"xMax"];
	
	[self willChangeValueForKey:@"arrangedObjects"];
}

-(void) didChangeData{
	[self didChangeValueForKey:@"yMin"];
	[self didChangeValueForKey:@"yMax"];
	[self didChangeValueForKey:@"xMin"];
	[self didChangeValueForKey:@"xMax"];
	
	[self didChangeValueForKey:@"arrangedObjects"];
} 

-(void) addProperty:(PluginProperty*)property{
	if(![properties containsObject:property]){
		[properties addObject:property];
		[property addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:@"propertyChange"];
		
		[data addObject:[NSMutableArray array] ];
		[newData addObject: [NSMutableArray array]  ];
		
		NSMutableArray * dispArray = [NSMutableArray array] ;
		
		NSTimeInterval t = -[startDate timeIntervalSinceNow];
		id x = [NSDecimalNumber numberWithDouble:t];
		id y = [NSDecimalNumber numberWithDouble:[[property value] floatValue]];
		
		[[data lastObject] addObject:[NSDictionary dictionaryWithObjectsAndKeys:x,@"x", y,@"y",nil]];
		[displayedData addObject:dispArray];
		
		GRDataSet * dataSet = [[[self dataSetClass] alloc] initWithOwnerChart: graphView] ;
		[dataSet setProperty: [NSNumber numberWithInt: 1] forKey: GRDataSetDrawPlotLine];
		[dataSet setProperty: [NSNumber numberWithInt: 0] forKey: @"GRDataSetDrawMarkers"];
		[dataSet setProperty: [NSNumber numberWithInt: 2] forKey: @"GRDataSetPlotLineWidth"];
		
		//		NSLog(@"Props %@",[dataSet properties]);
		[graphView addDataSet: dataSet loadData: YES];
		[dataSet release];
	}
	
}
-(void) removeProperty:(PluginProperty*)property{
	int index = [properties indexOfObject:property];
	if(index != NSNotFound){
		[data removeObjectAtIndex:index];
		[displayedData removeObjectAtIndex:index];
		[newData removeObjectAtIndex:index];
		[properties removeObject:property];			
		
		[graphView removeDataSet:[[graphView dataSets] objectAtIndex:index]];
	}
	[property removeObserver:self forKeyPath:@"value"]; 	
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([(NSString*)context isEqualToString:@"propertyChange"]){
		NSTimeInterval t = -[startDate timeIntervalSinceNow];
		id x = [NSDecimalNumber numberWithDouble:t];
		id y = [NSDecimalNumber numberWithDouble:[[change objectForKey:@"new"] floatValue]];
		int index = [properties indexOfObject:object];
		if(index != NSNotFound){
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil] ;
			dispatch_async(dispatch_get_main_queue(), ^{		
				[[newData objectAtIndex:index] addObject:dict];	
			});
		}
	}
	
}


-(IBAction) setRefreshRate:(id)sender{
	changeRefreshrateTo = [sender floatValue];
}


-(IBAction) reset:(id)sender{
	NSMutableArray * arrC;
	for(arrC in displayedData ){
		[arrC removeAllObjects];
	}
	
	NSMutableArray * arr;
	for(arr in data){
		[arr removeAllObjects];
	}
}


@end
