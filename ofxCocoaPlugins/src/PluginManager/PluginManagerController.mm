#import "PluginManagerController.h"
#include "Plugin.h"

#include "PluginListMeterCell.h"
#import "BeamSync.h"
#include "PluginOpenGLControlView.h"
#include "MainWindow.h"


PluginManagerController * globalController;

extern ofAppBaseWindow * window;

@implementation PluginManagerController 

@synthesize saveManager, statsAreaView, sharedOpenglContext, openglLock, fps, plugins, viewManager, qlabController;
@synthesize quitWithoutAsking;

#pragma mark Startup

-(id) init{
    self = [super init];
	if (self)
    {
		globalController = self;
		plugins = [[[NSMutableArray alloc] init] retain];	
		
		quitWithoutAsking = YES;
		
		setupAppCalled = NO;
		previews = YES;
		
		//NSBundle *bundle = [NSBundle mainBundle];
		//ofSetDataPathRoot([[[[bundle bundlePath] stringByDeletingLastPathComponent] stringByAppendingString:@"/data/"] cStringUsingEncoding:NSUTF8StringEncoding]);
        ofSetDataPathRoot("../../../data/");
        
		//Lock used by OpenGL
		openglLock = [NSRecursiveLock new];
		
		oscReceiver = new ofxOscReceiver();
		oscReceiver->setup(1111);
		
		isQuitting = NO;		
    }
	
    return self;
	
}

//
//------
//

-(void) awakeFromNib{
	[NSApp setDelegate: self];
    [mainWindow setDelegate:self];
	
	NSString * appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
	[mainWindow setTitle:appName];
	[[[[[NSApp mainMenu] itemAtIndex:0] submenu] itemWithTag:1] setTitle:[NSString stringWithFormat:@"About %@",appName]];
	[[[[[NSApp mainMenu] itemAtIndex:0] submenu] itemWithTag:2] setTitle:[NSString stringWithFormat:@"Hide %@",appName]];
	[[[[[NSApp mainMenu] itemAtIndex:0] submenu] itemWithTag:3] setTitle:[NSString stringWithFormat:@"Quit %@",appName]];
	
	setupAppCalled = YES;
	
	//Setup outputviews
	[viewManager setupScreen];
	
	//NSImage * hazardImage = [NSImage imageNamed:@"hazard stripes small.psd"];	
	//[pluginTitleView setFillColor:[NSColor colorWithPatternImage:hazardImage]];
	[pluginTitleView setFillColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.3]];
	
}

//
//------
//Getting called when all plugins have been defined
//

- (void) finishedDefinePlugins{
    
	[self willChangeValueForKey:@"plugins"];
	[self didChangeValueForKey:@"plugins"];
	
	//Call's all the initial init code. It's not the same as setup, that comes later when OpenGL is up and running
	[self initPlugins];
    
	
	//Properties cells setup
	PluginListMeterCell *infoCell = [[PluginListMeterCell alloc] init];
	[pluginMeterColumn setDataCell:infoCell];
	
	sliderCell = [[[NSSliderCell alloc] init] retain];
	[sliderCell setContinuous:YES];
	
	boolButtonCell = [[[NSButtonCell alloc] init] retain];
	[boolButtonCell setBezelStyle:  NSTexturedRoundedBezelStyle];
	[boolButtonCell setControlSize:NSMiniControlSize];
	[boolButtonCell setButtonType: NSOnOffButton ];
	
	textfieldCell = [[[NSTextFieldCell alloc] init] retain];
	
	[propertiesControlColumn setDataCell: sliderCell];
	[propertiesControlColumn bind:@"value" toObject:pluginPropertiesController withKeyPath:@"arrangedObjects.value.value" options:nil];
}


//
//------
//Calls initPlugin on all plugins, and updates the loadingscreen
//

-(void) initPlugins{
	NSLog(@"------ Init plugins: ------");	

	[mainWindow setLoadStatusText:[NSString stringWithFormat:@"Initing plugins 1/%d",[self countOfPlugins]]];

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //[[self openglLock] lock]; 

		//	dispatch_async(dispatch_get_main_queue(), ^{
		int i=0;
		for(NSDictionary * group in plugins){
			for(ofPlugin * plugin in [group objectForKey:@"children"]){
				dispatch_async(dispatch_get_main_queue(), ^{
					[mainWindow addPluginDetail:[plugin name] text:@"Initing...."];
				});
				dispatch_sync(dispatch_get_main_queue(), ^{
					[plugin initPlugin];
					[plugin loadPluginNibFile];
					[plugin setInitPluginCalled:YES];
				});
				dispatch_async(dispatch_get_main_queue(), ^{
					[mainWindow setPluginDetailNumber:i to:@"Inited"];
				
					[mainWindow setLoadPercentage:0.5*(float)(i+1)/[self countOfPlugins]];
					[mainWindow setLoadStatusText:[NSString stringWithFormat:@"Initing plugins %d/%d",i+1,[self countOfPlugins]]];
					
				});
				
				
				if(i ==  [self countOfPlugins]-1 && !pluginsInited){
					dispatch_sync(dispatch_get_main_queue(), ^{			
						[mainWindow setLoadStatusText:[NSString stringWithFormat:@"Loading file from disk"]];
					});
					dispatch_async(dispatch_get_main_queue(), ^{					
						//All plugins are done initing
						[saveManager loadLastDataFromDisk:self];
						[pluginsOutlineView expandItem:nil expandChildren:YES];
						//	[pluginsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:YES];
						[pluginsOutlineView deselectRow:0];
						[self changePlugin:self];
						[viewManager showViews];

						if([viewManager numberOutputViews] == 0){
							setupCalled = YES;						
							[mainWindow setFinishedLoading];						
						}
						
						pluginsInited = YES;
					});
				}
				
				i++;
			}			
		}
     //   [[self openglLock] unlock]; 

	});		   
	
}



//
//------
//


- (void)addPlugin:(ofPlugin*)obj {
	[obj setName:NSStringFromClass([obj class])];
	[obj retain];
	
	NSMutableArray * array = [[[self plugins] lastObject] objectForKey:@"children"];
	[array addObject:obj];	
}

//
//------
//

- (void)addHeader:(NSString *)header {
	[[self plugins] addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							   header,@"name",
							   [NSNumber numberWithBool:NO], @"canDisable",
							   [NSMutableArray array],@"children",
							   [NSMutableDictionary dictionary],@"properties",
							   [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"show", nil],@"powerMeterDictionary",
							   nil]];
}




//
//------
//

#pragma mark OpenGL


- (NSOpenGLContext*) getSharedContext:(CGLPixelFormatObj)pixelFormat{	
	
	NSOpenGLPixelFormat * nsPixelFormat = [[NSOpenGLPixelFormat alloc] initWithCGLPixelFormatObj:pixelFormat];
	
	if( sharedOpenglContext == nil )
	{
		NSOpenGLContext * newContext = [[NSOpenGLContext alloc] initWithFormat:nsPixelFormat shareContext:nil];
		[newContext retain];
		sharedOpenglContext = newContext;
		return newContext;
	} else {
		NSOpenGLContext * newContext = [[NSOpenGLContext alloc] initWithFormat:nsPixelFormat shareContext:sharedOpenglContext];
		return [newContext retain];
	}
}


//
//-------
//

- (void) callSetup{
	if(!isQuitting){
		NSLog(@"------ Call setup: ------");
		int n=0;
		for(NSDictionary * group in plugins){
			ofPlugin * plugin;
			for(plugin in [group objectForKey:@"children"]){		
				dispatch_async(dispatch_get_main_queue(), ^{
					[mainWindow setPluginDetailNumber:n to:@"Calling OpenGL setup..."];
					[mainWindow setLoadStatusText:[NSString stringWithFormat:@"OpenGL setup %d/%d",n+1,[self countOfPlugins]]];
				});

					
				if(![plugin setupCalled]){
					[plugin setup];
					[plugin setSetupCalled:YES];
				}
				dispatch_async(dispatch_get_main_queue(), ^{				
					[mainWindow setLoadPercentage:0.5+0.5*(float)(n+1)/[self countOfPlugins]];
					[mainWindow setPluginDetailNumber:n to:@"Done loading"];
				});
				
				
				n++;
			}
		}
		setupCalled = YES;
		NSLog(@"\n");
		NSLog(@"------ Running: ------");
		
		dispatch_async(dispatch_get_main_queue(), ^{		
			[mainWindow setFinishedLoading];	
		});
	}
}

//
//-----
//

- (void) callUpdate:(NSMutableDictionary*)drawingInformation{
	while( oscReceiver->hasWaitingMessages() ){
		ofxOscMessage m;
		oscReceiver->getNextMessage( &m );
		
		if ( m.getAddress() == "/outputviews/fullscreen" ){
			[viewManager goFullscreen]; 
		}
		if ( m.getAddress() == "/outputviews/window" ){
			[viewManager goWindow]; 
		}
		
		if ( m.getAddress() == "/pluginProperty/set" ){
			NSDictionary * group;
			for(group in plugins){
				ofPlugin * plugin;
				for(plugin in [group objectForKey:@"children"]){
					if([[plugin name] isEqualToString:[NSString stringWithCString:m.getArgAsString(0).c_str() encoding:NSUTF8StringEncoding]]){
						PluginProperty * prop = [[plugin properties] objectForKey:[NSString stringWithCString:m.getArgAsString(1).c_str() encoding:NSUTF8StringEncoding]];
						if(prop != nil){
							[prop setValue:[NSNumber numberWithFloat:m.getArgAsFloat(2)]];
						}
					}					
				}
			}	
		}		
	}
	
	
	NSDictionary * group;
	for(group in plugins){
		ofPlugin * plugin;
		for(plugin in [group objectForKey:@"children"]){
			int time = ofGetElapsedTimeMillis();
			if([[plugin enabled] boolValue] ){		
				[plugin update:drawingInformation];
			}
			
			NSArray * allProps = [[plugin properties] allValues];
			for(PluginProperty * prop in allProps){
				[prop update];
			}
			
			[plugin setUpdateCpuTime:ofGetElapsedTimeMillis()-time];
			
		}
	}
}


//
//-----
//

- (BOOL) willDraw:(NSMutableDictionary*)drawingInformation{
	BOOL draw = NO;
	
	NSDictionary * group;
	for(group in plugins){
		ofPlugin * plugin;
		for(plugin in [group objectForKey:@"children"]){			
			if(!isQuitting && [[plugin enabled]boolValue] ){				
				if([[plugin enabled] boolValue] && [plugin willDraw:drawingInformation]){
					draw = YES;
				}
			}
		}
	}
	
	return draw;
}


//
//-----
//


- (void) callDraw:(NSMutableDictionary*)drawingInformation {
	[self willChangeValueForKey:@"fps"];
	if([drawingInformation valueForKey:@"lastTime"] == nil){ 
		[drawingInformation setValue:[NSNumber numberWithFloat:(60)] forKey:@"fps"];
		
	} else {
		[drawingInformation setValue:[NSNumber numberWithFloat:( 1.0/([[drawingInformation valueForKey:@"timeInterval"] doubleValue]-[[drawingInformation valueForKey:@"lastTime"] doubleValue]))] forKey:@"fps"];
	}
	
	[self didChangeValueForKey:@"fps"];
	
	ofSetFrameRate([[drawingInformation valueForKey:@"fps"] doubleValue]);
	[drawingInformation setValue:[drawingInformation valueForKey:@"timeInterval"] forKey:@"lastTime"] ;
	
	startFrameTime = ofGetElapsedTimeMillis();
	
	
	NSAutoreleasePool * perFramePool = [[NSAutoreleasePool alloc] init];
	//Call update on all plugins
	[self callUpdate:drawingInformation];
	
	//Prepare opengl
	glClearColor(0,0,0,0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);     // Clear Screen data of the texture to write on
	
	
		
	for(NSDictionary * group in plugins){
		for(ofPlugin * plugin in [group objectForKey:@"children"]){
			
			glPushMatrix();
				
			if(!isQuitting && [[plugin enabled]boolValue] ){
				//	ofEnableAlphaBlending();
				//	glBlendColor([[plugin alpha] floatValue], [[plugin alpha] floatValue], [[plugin alpha] floatValue], [[plugin alpha] floatValue]);
				//	glBlendFuncSeparate(GL_CONSTANT_COLOR, GL_ONE_MINUS_CONSTANT_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_DST_ALPHA);
				glViewport(0, 0, ofGetWidth(), ofGetHeight());
				
				//Draw plugin
				[plugin draw:drawingInformation];
				
			}
			glPopMatrix();			
		}
	}
	
	
	
	//Calculate cpu usage
	if(ofGetElapsedTimeMillis() - lastPowerMeterUpdate > 100){	
		for(NSDictionary * group in plugins){
			for(ofPlugin * plugin in [group objectForKey:@"children"]){		
				[plugin setUpdateCpuUsage:([plugin updateCpuTime]==0)?0:(float)[plugin updateCpuTime]/(1000.0/ofGetFrameRate())];
				[plugin setDrawCpuUsage:([plugin drawCpuTime]==0)?0:(float)[plugin drawCpuTime]/(1000.0/ofGetFrameRate())];
			}
		}
		lastPowerMeterUpdate = ofGetElapsedTimeMillis();
	}
	
	[perFramePool drain];
	
}


//
//-----
//

- (BOOL) isSetupCalled{
	return setupCalled;
}


//
//-----
//


-(void)setNumberOutputViews:(int)n{
	[viewManager setNumberOutputViews:n];
}


//
//------
//

#pragma mark Plugins Management

- (int) countOfPlugins{
	int n = 0;
	NSDictionary * group;
	for(group in plugins){
		ofPlugin * plugin;
		for(plugin in [group objectForKey:@"children"]){	
			n++;
		}
	}
	return n;
}


//
//-------
//

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*) context isEqualToString:@"changePlugin"]){
		[self changePlugin:self];
	}
}


//
//-------
//


-(IBAction)changePlugin:(id)sender{
	[openglLock lock];
	if([[self selectedPlugin] view] != nil){		
        [[[self selectedPlugin] view] setFrame:[pluginControllerView bounds]];
        [pluginControllerView replaceSubview:[[pluginControllerView subviews] objectAtIndex:0] with:[[self selectedPlugin] view]];

        [self selectedPlugin].controlGlView.plugin = [self selectedPlugin];

	} else {
		[pluginControllerView replaceSubview:[[pluginControllerView subviews] objectAtIndex:0] with:[[[NSView alloc]initWithFrame:[[pluginControllerView superview] frame]]autorelease]];
		[pluginControllerView setAutoresizesSubviews:YES];	
		[pluginControllerView setAutoresizingMask: NSViewWidthSizable |  NSViewMaxXMargin | NSViewMinXMargin  | NSViewHeightSizable |  NSViewMaxYMargin | NSViewMinYMargin  ];
	}
	
	if([[[self selectedPlugin] properties] count] == 0){
		[[pluginSplitView animator] setPosition:0.0 ofDividerAtIndex:0];
        propertiesShown = NO;
	} else if([[self selectedPlugin] view] == nil){
		//		[pluginSplitView setPosition:1.0 ofDividerAtIndex:0];
		//		[pluginSplitView toggleCollapse:self];
		[[pluginSplitView animator] setPosition:600 ofDividerAtIndex:0];
		propertiesShown = YES;
		//BWSplitView 
	} else {
        if(propertiesShown){
			[[pluginSplitView animator] setPosition:20+[[[self selectedPlugin] properties] count]*20 ofDividerAtIndex:0];
        } else {
            [[pluginSplitView animator] setPosition:0 ofDividerAtIndex:0];
        }
	}
    
	[openglLock unlock];

}


//
//-----
//



- (BOOL) isPluginsInited{
	return pluginsInited;
}

//
//-----
//


- (ofPlugin*) getPlugin:(Class)pluginClass{
	NSDictionary * group;
	for(group in plugins){
		ofPlugin * plugin;
		for(plugin in [group objectForKey:@"children"]){			
			if([plugin isKindOfClass:pluginClass]){
				return plugin;
			}
		}
	}
    return nil;
}



//
//-----
//



-(ofPlugin *) selectedPlugin{
	return [[pluginsTreeController selectedObjects]	lastObject];
}



//
//-----
//



-(IBAction) toggleGraphView:(id)sender{
	if ([graphPanel isVisible]) {
		[self hideGraphView:sender];
		return;
	} else {
		[self showGraphView:sender];
	}	
}


#pragma mark GUI


-(IBAction) showGraphView:(id)sender{
	[toolbarGraphItem setLabel:@"Hide graph"];	
	[graphPanel makeKeyAndOrderFront:nil];
}

-(IBAction) hideGraphView:(id)sender{
	[graphPanel orderOut:nil];
	[toolbarGraphItem setLabel:@"Show graph"];
}

-(IBAction) pressToggleParametersButton:(id)sender{
    if(propertiesShown){
        propertiesShown = NO;
        [[pluginSplitView animator] setPosition:0 ofDividerAtIndex:0]; 

    } else {
        propertiesShown = YES;
        [[pluginSplitView animator] setPosition:20+[[[self selectedPlugin] properties] count]*20 ofDividerAtIndex:0]; 
    }  
}
/*
 -(IBAction) pressGraphViewButton:(id)sender{
 if([[globalGraphDebugger properties]count] >  0){
 [self showGraphView:self];		
 } else {
 [self hideGraphView:self];		
 }
 }*/





//
//-----
//




-(void) mouseUpPoint:(NSPoint)theEvent{
	//[[self getPlugin:[Tracking class]] mouseUpPoint:theEvent];
}
-(void) mouseDownPoint:(NSPoint)theEvent{
	//[[self getPlugin:[Tracking class]] mouseDownPoint:theEvent];
}
-(void) mouseDraggedPoint:(NSPoint)theEvent{
	//[[self getPlugin:[Tracking class]] mouseDraggedPoint:theEvent];
}




//
//------
//Outlineview delegates

#pragma mark Delegates

-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
	id node =  [item representedObject];
	if ([[node valueForKey:@"children"]count] > 0){
		return YES;
	}
	else{
		return NO;
	}
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item{
	id node =  [item representedObject];
	if ([[node valueForKey:@"children"]count] > 0){
		return YES;
	}
	else{
		return YES;
	}
	
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	id node = [item representedObject];
	if ([[node valueForKey:@"children"]count] > 0){
		return NO;
	}
	return YES;
}




//
//------
//Tableview delegates


-(NSCell *) tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	if([[tableColumn identifier] isEqualToString:@"control"]){
		PluginProperty * p = (PluginProperty *)[[[pluginPropertiesController arrangedObjects] objectAtIndex:row] value];
		NSCell * cell = [p controlCell];
		return cell;
		
	} else {
		return [tableColumn dataCellForRow:row];
	}
}




//---------
//-- Termination stuff
//---------

#pragma mark  Termination

- (void) applicationWillTerminate: (NSNotification *)note
{
    [BeamSync enable];

	[openglLock lock];
	
	isQuitting = YES;
	[saveManager saveDataToDisk:self];
	NSDictionary * group;
	for(group in plugins){
		ofPlugin * plugin;
		for(plugin in [group objectForKey:@"children"]){	
			[plugin applicationWillTerminate:note];
		}
	}
	
}
/*
-(void) encodeWithCoder:(NSCoder *)coder{
	NSLog(@"Encode");
	[coder encodeObject:plugins forKey:@"plugins"];
	//	[coder encodeObject:outputViewsScreensControl forKey:@"ouputViewsScreenControl"];
}

-(id) initWithCoder:(NSCoder *)coder{
	NSLog(@"Decode");
	[plugins initWithCoder:coder];
	
}*/


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app {
	if(quitWithoutAsking){
		return NSTerminateNow;
	} else {
		[self askToQuit:[app mainWindow]];
		return NSTerminateLater;
	}
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
	[[NSApplication sharedApplication] terminate:sender];
	return NO;
}

- (void)askToQuit:(NSWindow *) theWindow {
	[theWindow makeKeyAndOrderFront:nil];
	NSBeginAlertSheet(NSLocalizedString(@"Do you want to Quit?", @"Title of alert panel which comes up when user chooses Quit"),
					  NSLocalizedString(@"Quit", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
					  NSLocalizedString(@"Cancel", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),
					  nil,
					  theWindow,
					  self,
					  @selector(willEndCloseSheet:returnCode:contextInfo:),
					  @selector(didEndCloseSheet:returnCode:contextInfo:),
					  nil,
					  NSLocalizedString(@"If you quit, the show gotta be over.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents.")
					  );
}

- (void)willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertAlternateReturn) {     /* "Don't quit" */
		[NSApp replyToApplicationShouldTerminate:NO];
	}
	if (returnCode == NSAlertDefaultReturn) {       /* "Quit" */
		// we need to quit here explicitly as other windows would otherwise keep the updates runing causing a illegal reference to this closed window.
		[NSApp replyToApplicationShouldTerminate:YES];
	} 
}

- (void)didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertAlternateReturn) {     /* "Don't quit" */
		[NSApp replyToApplicationShouldTerminate:NO];
	}
	if (returnCode == NSAlertDefaultReturn) {       /* "Quit" */
		// we need to quit here explicitly as other windows would otherwise keep the updates runing causing a illegal reference to this closed window.
		[NSApp replyToApplicationShouldTerminate:YES];
	} 	
}

@end
