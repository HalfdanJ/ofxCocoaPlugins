#import "Keystoner.h"


@implementation Keystoner
@synthesize outputViews,  selectedOutputview, selectedSurface, selectedProjector, surfaces, font, recoilLogo, trackingLayer;

-(id) initWithSurfaces:(NSArray*)_surfaces{
	if([self init]){
		outputViews = [[NSMutableArray array] retain];
		willDraw = YES;
		surfaces = [_surfaces retain];
		
		PluginOpenGLView * outputView;
		int i=0;
		for(outputView in [[globalController viewManager] glViews]){
			KeystonerOutputview * newView = [[KeystonerOutputview alloc]initWithSurfaces:surfaces];
			[newView setViewNumber:i];
			[outputViews addObject:newView];
			i++;
		}
		
		[self addObserver:self forKeyPath:@"customProperties" options:nil context:@"customProperties"];
		[self addObserver:self forKeyPath:@"selectedSurfaceIndexSet" options:nil context:@"outputView"];
	}
	
	return self;
}

-(void) applySurface:(NSString*)surfaceName projectorNumber:(int)projectorNumber viewNumber:(int)viewNumber{
	if(appliedSurface != nil){
		NSLog(@"Surface was already applied. Pop first!");
		[self popSurface];
	}
	
	glPushMatrix();
	[[outputViews objectAtIndex:viewNumber] applySurface:surfaceName projectorNumber:projectorNumber];
	
	appliedSurface = [self getSurface:surfaceName viewNumber:viewNumber projectorNumber:projectorNumber];
}

-(void) popSurface{
	if(appliedSurface != nil){
		int part = [appliedSurface softedgePart];
		int numParts = [appliedSurface softedgeTotalParts];
		
		float margin = 0.05;
		ofEnableAlphaBlending();
		ofSetColor(0, 0, 0,255);
		if(part > 1 && numParts > 1){
			glPushMatrix();
			ofEnableAlphaBlending();
			
			float point = (float)(part-1)/numParts;
			glScaled([[appliedSurface aspect] floatValue], 1, 1);
			
			glBegin(GL_QUAD_STRIP);
			glColor4f(0.0,0.0,0.0,1.0);
			glVertex2f(-10, 0);
			glVertex2f(-10,1.0);
			
			glColor4f(0.0,0.0,0.0,1.0);
			glVertex2f(point-margin, 0);
			glVertex2f(point-margin,1.0);
			//alpha color
			glColor4f(0.0,0.0,0.0,0.0);
			glVertex2f(point+margin, 0);
			glVertex2f(point+margin,1.0);
			
			glEnd();
			
			
			//gammaFade->draw(point-margin, -1,margin*2,3);
			
			
			
			//glColor4f(1.0, 1.0, 1.0, 1.0);
			//ofLine((float)(part-1)/numParts, 0, (float)(part-1)/numParts, 1);
			
			glPopMatrix();
		}
		
		
		if(part < numParts){
			glPushMatrix();
			ofEnableAlphaBlending();
			
			float point = (float)(part)/numParts;
			glScaled([[appliedSurface aspect] floatValue], 1, 1);
			
			glBegin(GL_QUAD_STRIP);
			glColor4f(0.0,0.0,0.0,1.0);
			glVertex2f(10, 0);
			glVertex2f(10,1.0);
			
			glColor4f(0.0,0.0,0.0,1.0);
			glVertex2f(point+margin, 0);
			glVertex2f(point+margin,1.0);
			//alpha color
			glColor4f(0.0,0.0,0.0,0.0);
			glVertex2f(point-margin, 0);
			glVertex2f(point-margin,1.0);			
			glEnd();
			
			//	gammaFade->draw(point+margin, -1,-margin*2,3);
			
			
			
			glColor4f(1.0, 1.0, 1.0, 1.0);
			//ofLine((float)(part)/numParts, 0, (float)(part)/numParts, 1);
			glPopMatrix();
		}
		
		
		glPopMatrix();	
		glViewport(0, 0, ofGetWidth(), ofGetHeight());
		
		appliedSurface = nil;
	} 
	
	
}

-(void) draw:(NSDictionary *)drawingInformation{
	int viewNo = ViewNumber;
	NSArray * projectors = [[[outputViewController arrangedObjects] objectAtIndex:viewNo] projectors];
	KeystoneProjector * projector;
	for(projector in projectors){
		if([[[projector surfaces]objectAtIndex:[surfaceArrayController selectionIndex]] visible]){
			[self applySurface:[[[projector surfaces]objectAtIndex:[surfaceArrayController selectionIndex]] name] projectorNumber:[projector projectorNumber] viewNumber:ViewNumber];
			if([drawSettings selectedSegment] == 1){
				KeystoneSurface * theSurface = [[projector surfaces]objectAtIndex:[surfaceArrayController selectionIndex]];
				[theSurface drawGridSimple:([theSurface projectorNumber] == [projectorArrayController selectionIndex] && ViewNumber==[outputViewController selectionIndex])?NO:YES];
			}
			if([drawSettings selectedSegment] == 2){
				ofSetColor(255, 255, 255);
				
				ofRect(0,0,[[[[projector surfaces]objectAtIndex:[surfaceArrayController selectionIndex]] aspect] floatValue],1);
			}
			
			[self popSurface];
		}
		
		
	}
	
	
	willDraw = NO;
}	

-(BOOL) willDraw:(NSMutableDictionary*)drawingInformation{
	return YES;
	//return willDraw || [drawSettings selectedSegment];
}

-(NSMutableDictionary *) customProperties{
	NSMutableArray * keystoneSaveableInformation = [NSMutableArray array];
	
	NSMutableDictionary * props = customProperties;
	[props setObject:keystoneSaveableInformation forKey:@"outputviews"];
	
	KeystonerOutputview * outputview;
	for(outputview in outputViews){
		NSMutableArray * viewProjectors = [NSMutableArray array];
		KeystoneProjector * proj;
		for(proj in [outputview projectors]){
			NSMutableArray * projectorSurfaces = [NSMutableArray array];				
			KeystoneSurface * surface;
			for(surface in [proj surfaces]){
				NSMutableDictionary * infoDict = [NSMutableDictionary dictionary];
				[infoDict setObject:[surface cornerPositions] forKey:@"cornerPositions"];
				[infoDict setObject:[surface aspect] forKey:@"aspect"];		
				[infoDict setObject:[NSNumber numberWithBool:[surface visible]] forKey:@"visible"];					
				[infoDict setObject:[NSNumber numberWithInt:[surface softedgePart]] forKey:@"softedgePart"];					
				[infoDict setObject:[NSNumber numberWithInt:[surface softedgeTotalParts]] forKey:@"softedgeTotalParts"];					
				
				[projectorSurfaces addObject:infoDict];
			}
			
			[viewProjectors addObject:projectorSurfaces];
		}
		[keystoneSaveableInformation addObject:viewProjectors];
		
	}
	
	return props;
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"customProperties"]){
		NSArray * viewsArray = [customProperties objectForKey:@"outputviews"];
		
		KeystonerOutputview * outputview;
		int viewi=0;
		for(outputview in outputViews){
			if([viewsArray count] > viewi){
				NSArray * projArray = [viewsArray objectAtIndex:viewi];
				int proji=0;
				//	for(proj in [outputview projectors]){
				for(NSArray * surfArray in projArray){
					KeystoneProjector * newProj;
					if([[outputview projectors] count] <= proji){
						newProj =  [[[KeystoneProjector alloc] initWithSurfaces:surfaces viewNumber:viewi projectorNumber:proji] autorelease];
						[[outputview projectors] addObject:newProj];
					} else {
						newProj = [[outputview projectors] objectAtIndex:proji];
					}
					/*if(proji == 0 && viewi == 0)
					 [projectorArrayController setSelectedObjects:[NSArray arrayWithObject:newProj]];
					 */
					/*	if(proji == 0 && viewi == 0){
					 NSAssert(newProj != [[projectorArrayController selectedObjects] lastObject], @"projector not selected");
					 NSLog(@"Projector selected");
					 }
					 */
					int surfi=0;
					for(KeystoneSurface * surface in [newProj surfaces]){
						NSMutableDictionary * infoDict  = [surfArray objectAtIndex:surfi];
						[surface setAspect:[infoDict objectForKey:@"aspect"]];
						[surface setCornerPositions:[infoDict objectForKey:@"cornerPositions"]];
						[surface setVisible:[[infoDict objectForKey:@"visible"] boolValue]];
						[surface setSoftedgePart:[[infoDict objectForKey:@"softedgePart"] intValue]];
						[surface setSoftedgeTotalParts:[[infoDict objectForKey:@"softedgeTotalParts"] intValue]];
						
						/*if(surfi == 0 && proji == 0 && viewi == 0){
						 NSAssert(surface != [[surfaceArrayController selectedObjects] lastObject], @"surface not selected");
						 NSLog(@"surface selected");	
						 }	*/
						//								[surfaceArrayController setSelectedObjects:[NSArray arrayWithObject:surface]];
						//	[surfaceArrayController setSelectionIndex:0];
						//								[infoDict setObject:[surface cornerPositions] forKey:@"cornerPositions"];
						//							[infoDict setObject:[surface aspect] forKey:@"aspect"];					
						//							[projectorSurfaces addObject:infoDict];
						surfi++;
						
						
					}
					proji++;
					
				}
				
			}
			viewi++;
			
		}
		
		[self updateProjectorButtons];
		
		/*		[surfaceArrayController unbind:@"contentArray"];
		 [projectorArrayController unbind:@"contentArray"];
		 [projectorArrayController bind:@"contentArray" toObject:outputViewController withKeyPath:@"selection.projectors" options:nil];
		 [surfaceArrayController bind:@"contentArray" toObject:projectorArrayController withKeyPath:@"selection.surfaces" options:nil];*/
		
		//		[trackingArea.layer setHandlePositionHolder:[[[surfaceArrayController selectedObjects] lastObject] cornerPositions]];
		//		[trackingArea.layer bind:@"handlePositionHolder" toObject:surfaceArrayController withKeyPath:@"selection.cornerPositions" options:nil];
		
	}
	
	if([(NSString*)context isEqualToString:@"outputView"]){
		int count = [[[[outputViewController selectedObjects] lastObject] projectors] count];
		if(count != [projectorPicker segmentCount] && count > 0){
			[projectorPicker setSegmentCount:count];
			[projectorPicker setSelectedSegment:0];
			for(int i=0;i<count; i++){
				[projectorPicker setLabel:[NSString stringWithFormat:@"%i",i] forSegment:i];
				[projectorPicker setWidth:0 forSegment:i];
			}
		}
		
		[self updateProjectorButtons];
		//	count = [[[[projectorArrayController selectedObjects] lastObject] surfaces] count];
	}
}


-(BOOL) autoresizeControlview{
	return YES;
}

-(void) initPlugin{
	selectedSurfaceCorner = -1;
}

-(void) setup{	
	gammaFade = new ofImage();
	gammaFade->loadImage("gammaFade.png");
}

-(void) setCornerArray:(NSMutableArray*)array{
	[[globalController openglLock] lock];
	[[[surfaceArrayController selectedObjects] lastObject] setCornerPositions:array];
	[[globalController openglLock] unlock];
}

-(void)awakeFromNib{
	[outputViewPicker setSegmentCount:[[globalController viewManager] numberOutputViews]];
	
	int i=0;
	KeystonerOutputview * outputView;
	for(outputView in outputViews){
		[outputViewPicker setLabel:[NSString stringWithFormat:@"%i",i] forSegment:i];
		[outputViewPicker setWidth:0 forSegment:i];
		i++;
	}
	
	[surfacePicker	setSegmentCount:[surfaces count]];
	NSString * surfaceName;
	i=0;
	for(surfaceName in surfaces){
		[surfacePicker setLabel:surfaceName forSegment:i];
		[surfacePicker setWidth:0 forSegment:i];
		
		i++;		
	}	
	/*
	 trackingLayer = [TrackingLayer layer];
	 
	 CGRect viewFrame = NSRectToCGRect( trackingArea.frame );
	 
	 trackingLayer.frame = viewFrame;
	 
	 
	 
	 //[trackingLayer setTransform:CATransform3DMakeScale( 0.7, 0.7, 1.0 )];
	 
	 
	 
	 [trackingArea setLayer:trackingLayer];
	 [trackingArea setWantsLayer:YES];
	 [trackingLayer setDataTarget:self];
	 [trackingLayer setup];
	 [trackingArea.layer bind:@"aspect" toObject:outputViewController withKeyPath:@"selection.aspect" options:nil];
	 [trackingArea.layer bind:@"visible" toObject:surfaceArrayController withKeyPath:@"selection.visible" options:nil];
	 [trackingArea.layer bind:@"handlePositionHolder" toObject:surfaceArrayController withKeyPath:@"selection.cornerPositions" options:nil];
	 
	 [self addObserver:trackingArea.layer forKeyPath:@"visible" options:nil context:@"positions"];
	 
	 [trackingLayer setScale:0.6];*/
	
	[super awakeFromNib];
	
}

-(NSRect) projectorControlRect{
	NSRect ret;
	
	int _window = [self selectedOutputview];
	int _projector = [self selectedProjector];
	
	KeystonerOutputview * outputView = [outputViews objectAtIndex:_window];
	KeystoneProjector * projector = [[outputView projectors] objectAtIndex:_projector];
	
	NSSize projectorSize = [outputView size];
	projectorSize.width /= [[outputView projectors] count];
	
	float aspectProjector = (float)projectorSize.width / projectorSize.height;
	float aspectContol = (float)controlWidth / controlHeight;
	
	float scale = 0.7;
	
	if(aspectContol < aspectProjector){
		//Vinduet er smallere end projektoren
		ret.size.width = controlWidth * scale;
		ret.size.height = ret.size.width / aspectProjector;
	} else {
		ret.size.height = controlHeight * scale;
		ret.size.width = ret.size.height * aspectProjector;
	}	
	
	ret.origin.x = controlWidth *0.5 - ret.size.width * 0.5;
	ret.origin.y = controlHeight *0.5 - ret.size.height * 0.5;
	
	return ret;
}

-(NSPoint) convertMouseToProjectorX:(int)x y:(int)y{
	NSPoint p;
	p.x = x;
	p.y = y;
	
	NSRect rect = [self projectorControlRect];
	p.x -= rect.origin.x;
	p.y -= rect.origin.y;
	
	p.x /= rect.size.width;
	p.y /= rect.size.height;
	
	return p;
}

-(KeystoneSurface*) selectedSurfaceObject{
	int _window = [self selectedOutputview];
	int _projector = [self selectedProjector];
	int _surface = [self selectedSurface];
	
	KeystonerOutputview * outputView = [outputViews objectAtIndex:_window];
	KeystoneProjector * projector = [[outputView projectors] objectAtIndex:_projector];
	KeystoneSurface * surface = [[projector surfaces] objectAtIndex:_surface];
	
	return surface;
}

-(void) controlDraw:(NSDictionary *)drawingInformation{
	ofEnableAlphaBlending();
	
	controlWidth = ofGetWidth();
	controlHeight = ofGetHeight();
	
	//Tegn selected projector
	int _window = [self selectedOutputview];
	int _projector = [self selectedProjector];
	int _surface = [self selectedSurface];
	
	KeystonerOutputview * outputView = [outputViews objectAtIndex:_window];
	KeystoneProjector * projector = [[outputView projectors] objectAtIndex:_projector];
	KeystoneSurface * surface = [[projector surfaces] objectAtIndex:_surface];
	
	NSSize viewSize = [outputView size];
	NSSize projectorSize = viewSize;
	projectorSize.width /= [[outputView projectors] count];
	
	NSRect rect = [self projectorControlRect];
	
	
	ofFill();
	ofSetColor(237, 237, 237,255);
	ofRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	ofNoFill();
	ofSetColor(150, 150, 150, 255);
	ofRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	if([surface visible]){		
		glPushMatrix();
		

		ofSetCircleResolution(30);
		ofNoFill();
		
		for(int i=0;i<4;i++){
			ofSetColor(150, 150, 200);
			if(selectedSurfaceCorner == i)
				ofSetColor(255, 120, 150);
			NSDictionary * p1 = [[surface cornerPositions] objectAtIndex:i];
			ofCircle(rect.origin.x+rect.size.width*[[p1 valueForKey:@"x"]floatValue], rect.origin.y+rect.size.height*(1-[[p1 valueForKey:@"y"]floatValue]), 8);
		}
		
		glTranslated(rect.origin.x, rect.origin.y, 0);
		glScaled(rect.size.width, rect.size.height, 1.0);
		
		
		[surface apply];{
			float resolution = 14.0;
			
			
			ofSetLineWidth(1);
			ofSetColor(150, 150, 150, 255);
			int xNumber = resolution+floor(([[surface aspect] floatValue]-1)*resolution);
			int yNumber = resolution;
			
			for(int i=0;i<=yNumber;i++){
				ofLine(0, i*1.0/resolution, [[surface aspect] floatValue], i*1.0/resolution);
			}			
			int xNumberCentered = xNumber;			
			if (xNumber%2 == 1) {
				xNumberCentered--;
			}
			for(int i=0;i<=xNumberCentered;i++){
				ofLine(((i*1.0/resolution)-((xNumberCentered/resolution)*0.5))+(0.5*[[surface aspect] floatValue]), 0, ((i*1.0/resolution)-((xNumberCentered/resolution)*0.5))+(0.5*[[surface aspect] floatValue]), 1.0);
				
			}
			
			//white sides
			ofLine([[surface aspect] floatValue], 0, [[surface aspect] floatValue], 1);
			ofLine(0, 0, 0, 1);
			
			
			
			ofSetColor(0, 0, 0, 255);		
			//up arrow
			glBegin(GL_POLYGON);{
				glVertex2f(([[surface aspect] floatValue]*0.5), 0);
				glVertex2f(([[surface aspect] floatValue]*0.5)-(0.05), 1.0/resolution);
				glVertex2f(([[surface aspect] floatValue]*0.5)+(0.05), 1.0/resolution);
				glVertex2f(([[surface aspect] floatValue]*0.5), 0);		
			} glEnd();
			ofNoFill();
			
			glBegin(GL_POLYGON);{
				
				glVertex2f(([[surface aspect] floatValue]*0.5)-(0.05), 1.0);
				glVertex2f(([[surface aspect] floatValue]*0.5), 1.0-(1.0/resolution));
				glVertex2f(([[surface aspect] floatValue]*0.5)+(0.05), 1.0);
				
			} glEnd();
			
			// center cross
			ofLine(([[surface aspect] floatValue]*0.5)-0.05, 0.5, ([[surface aspect] floatValue]*0.5)+0.05, 0.5);
			ofLine(([[surface aspect] floatValue]*0.5), 1.0/resolution, ([[surface aspect] floatValue]*0.5), 1.0-(0.5/resolution));
			
			
			
		}
		
		glPopMatrix();
	}[self popSurface];
	
	
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	NSRect rect = [self projectorControlRect];
	float d = 1.0/rect.size.width * 10.0;
	
	selectedSurfaceCorner = -1;
	
	NSPoint p = [self convertMouseToProjectorX:x y:y];
	
	for(int i=0;i<4;i++){
		NSDictionary * ps = [[[self selectedSurfaceObject] cornerPositions] objectAtIndex:i];
		NSPoint p2;
		p2.x = [[ps valueForKey:@"x"] floatValue];
		p2.y = 1-[[ps valueForKey:@"y"] floatValue];		
		
		float x = p.x-p2.x;
		float y = p.y-p2.y;
		
		if(sqrt(x*x + y*y) < d){
			selectedSurfaceCorner = i;
		}

	}
	
	
}

-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
	if(selectedSurfaceCorner != -1){
		
	}
}

-(void) controlMouseReleased:(float)x y:(float)y{
	selectedSurfaceCorner = -1;
}

//Outputview
-(void) setSelectedOutputview:(int)v{
	int theSurfaceSelection = selectedSurface;
	[self willChangeValueForKey:@"selectedOutputviewIndexSet"];
	selectedOutputview = v;
	[self didChangeValueForKey:@"selectedOutputviewIndexSet"];
	if (theSurfaceSelection >= 0 && theSurfaceSelection < [surfacePicker segmentCount]) {
		[self setSelectedSurface:theSurfaceSelection];
	}	
}

-(NSIndexSet * ) selectedOutputviewIndexSet{
	return [NSIndexSet indexSetWithIndex:selectedOutputview];
}

-(void) setSelectedOutputviewIndexSet:(NSIndexSet *)s{
	[self setSelectedOutputview:[s firstIndex]];
}


//Projector
-(void) setSelectedProjector:(int)v{
	int theSurfaceSelection = selectedSurface;
	[self willChangeValueForKey:@"selectedProjectorIndexSet"];
	selectedProjector = v;
	if (theSurfaceSelection >= 0 && theSurfaceSelection < [surfacePicker segmentCount]) {
		[self setSelectedSurface:theSurfaceSelection];
	}
	[self didChangeValueForKey:@"selectedProjectorIndexSet"];
	
}

-(NSIndexSet * ) selectedProjectorIndexSet{
	return [NSIndexSet indexSetWithIndex:selectedProjector];
}

-(void) setSelectedProjectorIndexSet:(NSIndexSet *)s{
	[self setSelectedProjector:[s firstIndex]];
}

-(IBAction) setViewMode:(id)sender{
	willDraw = YES;	
}

//Surface
-(void) setSelectedSurface:(int)v{
	[self willChangeValueForKey:@"selectedSurfaceIndexSet"];
	selectedSurface = v;
	[self didChangeValueForKey:@"selectedSurfaceIndexSet"];
}

-(NSIndexSet * ) selectedSurfaceIndexSet{
	return [NSIndexSet indexSetWithIndex:selectedSurface];
}

-(void) setSelectedSurfaceIndexSet:(NSIndexSet *)s{
	[self setSelectedSurface:[s firstIndex]];
}

-(KeystoneSurface*) getSurface:(NSString*)name viewNumber:(int)number projectorNumber:(int)projectorNumber{
	NSArray * theSurfaces = [[[[[outputViewController arrangedObjects] objectAtIndex:number] projectors] objectAtIndex:projectorNumber] surfaces];
	
	KeystoneSurface * theSurface;
	for(theSurface in theSurfaces){
		if([[theSurface name] isEqualToString:name]){
			return theSurface;
		}
	}
	return nil;
}

-(KeystoneSurface*) getSurface:(NSString*)name viewName:(NSString*)viewName projectorNumber:(int)projectorNumber{
	
	KeystonerOutputview * outputView;
	for(outputView in [outputViewController arrangedObjects]){
		if([[outputView name] isEqualToString:viewName]){
			NSArray * surfaces = [[[outputView projectors] objectAtIndex:projectorNumber] surfaces];
			KeystoneSurface * surface;
			for(surface in surfaces){
				if([[surface name] isEqualToString:name]){
					return surface;
				}
			}
		}
	}
	return nil;
}

-(IBAction) addProjector:(id)sender{
	KeystonerOutputview * selectedOutputView = [[outputViewController selectedObjects] lastObject];
	int count = [[selectedOutputView projectors] count];
	KeystoneProjector * proj =  [[[KeystoneProjector alloc] initWithSurfaces:surfaces viewNumber:[selectedOutputView viewNumber] projectorNumber:count] autorelease];
	[[selectedOutputView projectors] addObject:proj];
	
	[self updateProjectorButtons];	
}

-(IBAction) removeProjector:(id)sender{
	KeystonerOutputview * selectedOutputView = [[outputViewController selectedObjects] lastObject];
	[[selectedOutputView projectors] removeLastObject];
	
	[self updateProjectorButtons];	
}

-(void) updateProjectorButtons{
	KeystonerOutputview * selectedOutputView = [[outputViewController selectedObjects] lastObject];
	int count = [[selectedOutputView projectors] count];
	
	if([projectorPicker selectedSegment] >= count && count > 0){
		[projectorPicker setSelectedSegment:count-1];	
	}
	
	[projectorPicker setSegmentCount:count];
	if(count> 0){
		for(int i=0;i<count; i++){
			[projectorPicker setLabel:[NSString stringWithFormat:@"%i",i] forSegment:i];
			[projectorPicker setWidth:0 forSegment:i];
		}
		
		[projectionPlusButton setEnabled:YES];
		[projectionMinusButton setEnabled:YES];
		if(count == 1){
			[projectionMinusButton setEnabled:NO];			
		}
	}
}
@end
