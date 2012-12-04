#import <ofxCocoaPlugins/OSCControl.h>
#import <ofxCocoaPlugins/Tracker.h>
#import <ofxCocoaPlugins/Keystoner.h>
#import <ofxCocoaPlugins/Midi.h>

@implementation OSCControl

- (id)init{
    self = [super init];
    if (self) {
        
        
        [self addPropB:@"generate"];
    }
    
    return self;
}

//
//----------------
//



-(void) createInterface {
    {    
        ofxOscMessage m;
        m.setAddress( "/control/createBlankInterface" );    
        m.addStringArg( "ofxCocoaPlugins" );
        m.addStringArg( "landscape" );
        sender->sendMessage( m );
    }
    {    
        ofxOscMessage m;
        m.setAddress( "/control/pushDestination" );    
        m.addStringArg( "HalfdanJ.local:9090" );
        sender->sendMessage( m );
    }
}


- (string)dictToJson:(NSDictionary*) dict{
    string s = "{";
    for(NSString * key in dict){
        s.append("'");
        s.append([key cStringUsingEncoding:NSUTF8StringEncoding]);
        s.append("':");
        
        id value = [dict valueForKey:key];
        if([value isKindOfClass:[NSString class]]){
            if([key isEqualToString:@"bounds"]){
                s.append([value cStringUsingEncoding:NSUTF8StringEncoding]);                
            } else {
                s.append("'");
                s.append([value cStringUsingEncoding:NSUTF8StringEncoding]);
                s.append("'");
            }
        } else if([value isKindOfClass:[NSNumber class]]){
            s.append([[NSString stringWithFormat:@"%@", value] cStringUsingEncoding:NSUTF8StringEncoding]);            
        }
        s.append(", ");
    }
    s.append("}");
    return s;
}

- (NSString*) rectToBoundsString:(NSRect)rect{
    return [NSString stringWithFormat:@"[%f,%f,%f,%f]", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (void)addWidget:(NSDictionary*)json{
    string s = [self dictToJson:json];
   // cout<<s<<endl;
    
    ofxOscMessage m;
    m.setAddress( "/control/addWidget" );    
    m.addStringArg( s );
    sender->sendMessage( m );
    
}

//mode: There are 5 different possible modes for buttons. The default value is toggle.
//  toggle: Alternates between the buttons min and max values on each press

//  momentary: Outputs max when button is pressed, min when button is released 
//      or when touch travels outside button     boundaries

//  latch: Outputs max when button is pressed, min when button is released. 
//      As opposed to momentary, this does not release when the touch travels 
//      outside the button boundaries, only when the touch that initially triggered the button ends

//  contact: The button only outputs the max value, and only when it is first pressed.

//  visualToggle: The button always outputs max but toggles on and off visually (useful in some MIDI circumstances)

- (void) addButton:(NSString*)name label:(NSString*)label labelSize:(int)labelSize bounds:(NSRect)bounds mode:(NSString*)mode{
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     name, @"name",
                     @"Button",@"type",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                     [NSString stringWithFormat:@"%i",labelSize], @"labelSize",
                     @"#ccc", @"color",                     
                     label, @"label",
                     mode, @"mode",
                     nil]];
}

- (void) addButton:(NSString*)label labelSize:(int)labelSize bounds:(NSRect)bounds bindedTo:(PluginProperty*)property{
    NSAssert(property, @"No property");
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]], @"name",
                     @"Button",@"type",
                     [NSString stringWithFormat:@"/%@/%@",[property pluginName], [property name]], @"address",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                     [NSString stringWithFormat:@"%i",labelSize], @"labelSize",
                     label, @"label",
                     @"toggle", @"mode",
                     nil]];
    [property addObserver:self forKeyPath:@"value" options:nil context:@"property"];
    
    [self setColor:[NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]] background:@"rgb(0,0,0)" foreground:@"rgb(80,100,80)" stroke:@"rgb(255,255,255)"];
}

- (void) addFader:(NSString*)label bounds:(NSRect)bounds bindedTo:(PluginProperty*)property{
    NSAssert(property, @"No property");
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]], @"name",
                     @"Slider",@"type",
                     [NSString stringWithFormat:@"/%@/%@",[property pluginName], [property name]], @"address",
                     @"true", @"isVertical",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                //     label, @"label",
                     nil]];
    [property addObserver:self forKeyPath:@"value" options:nil context:@"property"];
    
    [self setColor:[NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]] background:@"rgb(0,0,0)" foreground:@"rgb(80,100,80)" stroke:@"rgb(255,255,255)"];
}

- (void) addMultiXY:(NSString*)name bounds:(NSRect)bounds isMomentary:(BOOL)isMomentary maxTouches:(int)maxTouches{
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     name, @"name",
                     @"MultiTouchXY",@"type",
                     [self rectToBoundsString:bounds], @"bounds",
                     [NSNumber numberWithBool:isMomentary], @"isMomentary",
                     [NSNumber numberWithBool:true], @"sendZValue",
                     [NSNumber numberWithInt:maxTouches], @"maxTouches",
                     nil]];
}

- (void) setColor:(NSString*)widget background:(NSString*)background foreground:(NSString*)foreground stroke:(NSString*)stroke {
    
    ofxOscMessage m;
    m.setAddress( "/control/setColors" );    
    m.addStringArg( [widget cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [background cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [foreground cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [stroke cStringUsingEncoding:NSUTF8StringEncoding] );
    sender->sendMessage( m );
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*) context isEqualToString:@"property"]){
        if(sender != nil){
            
            ofxOscMessage msg;
            msg.setAddress([[NSString stringWithFormat:@"/%@/%@",[object pluginName], [object name]] cStringUsingEncoding:NSUTF8StringEncoding]);
       //     msg.setAddress("/menuButton");
            msg.addFloatArg([object floatValue]);
            
            sender->sendMessage(msg);
        }
    }
}



-(void)setup{
    
    if(sender != nil){
        
        delete sender;
        delete receiver;
    }
    
    sender = new ofxOscSender();
    receiver = new ofxOscReceiver();
    
    sender->setup("HalfdanJ-iPad.local", 8080);
    // sender->setup("10.0.1.3", 8080);
    receiver->setup(9090);
    
    
    }


-(void) generateInterface{
    [self createInterface];
    
    
    /*  [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
     @"test2", @"name",
     @"Slider",@"type",
     @"[.0,.4,.75,.3]",@"bounds",
     nil]];
     */
    float x = 0.76;
    float w = 0.24;
    float h = 0.09;
    
    /*[self addButton:@"Tracker debug" labelSize:16 bounds:NSMakeRect(x, 0.0, w, h) bindedTo:[[GetPlugin(Tracker) properties] objectForKey:@"drawDebug"]];
     [self addButton:@"Keystone debug" labelSize:16 bounds:NSMakeRect(x, 0.1, w, h) bindedTo:[[GetPlugin(Keystoner) properties] objectForKey:@"Enabled"]];
     
     // [self addFader:@"Pub" bounds:NSMakeRect(x, 0.2, w/3.0, h) bindedTo:[[GetPlugin(Mask) properties] objectForKey:@"publys"]];
     
     [self addButton:@"Left blind" labelSize:16 bounds:NSMakeRect(x, 0.4, w*0.5, h) bindedTo:[[GetPlugin(Mask) properties] objectForKey:@"leftBlind"]];
     [self addButton:@"Right blind" labelSize:16 bounds:NSMakeRect(x+w*0.5, 0.4, w*0.5, h) bindedTo:[[GetPlugin(Mask) properties] objectForKey:@"rightBlind"]];
     
     [self addButton:@"Triangle white" labelSize:16 bounds:NSMakeRect(x, 0.5, w*0.5, h) bindedTo:[[GetPlugin(Mask) properties] objectForKey:@"triangleWhiteRight"]];
     [self addButton:@"Triangle black" labelSize:16 bounds:NSMakeRect(x+w*0.5, 0.5, w*0.5, h) bindedTo:[[GetPlugin(Mask) properties] objectForKey:@"triangleBlack"]];
     
     [self addButton:@"GO" labelSize:18 bounds:NSMakeRect(x, 0.65, w, h) bindedTo:[[GetPlugin(Midi) properties] objectForKey:@"qlabGo"]];
     
     */
    [self addMultiXY:@"trackerxy" bounds:NSMakeRect(0.0, 0.0, 0.75, 1.0) isMomentary:true maxTouches:3];
    [self setColor:@"trackerxy" background:@"#000" foreground:@"#aaa" stroke:@"#ddd"];
    
    //    [self addButton:@"but1" label:@"Tracker debug" labelSize:10 bounds:NSMakeRect(0.8, 0.0, 0.2, 0.1) mode:@"toggle"];

}
//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    if(PropB(@"generate")){
        SetPropB(@"generate", NO);
        //[self setup];
        [self generateInterface];
        
        for(int i=0;i<10;i++){
                trackerData[i].active = false;
        }
    }
    
    while( receiver->hasWaitingMessages() )
	{
		// get the next message
		ofxOscMessage m;
		receiver->getNextMessage( &m );
   //     cout<<"OSC: "<<m.getAddress()<<"  "<<m.getNumArgs()<<endl;
        
        for(int i=0;i<10;i++){
            if(m.getAddress() == "/trackerxy/"+ofToString(i)){
                trackerData[i].point.x = m.getArgAsFloat(0);
                trackerData[i].point.y = m.getArgAsFloat(1);
                trackerData[i].active = m.getArgAsFloat(2);
                
            } 
            else {
                NSString * adr = [NSString stringWithCString:m.getAddress().c_str() encoding:NSUTF8StringEncoding];
                NSArray * splits = [adr componentsSeparatedByString:@"/"];
                
                if([splits count] == 3){
                    for(NSDictionary * header in [globalController plugins]){  
                        for(ofPlugin * otherPlugin in [header valueForKey:@"children"]){
                            for(PluginProperty * property in [[otherPlugin properties] allValues]){
                                if([[property pluginName] isEqualToString:[splits objectAtIndex:1]] && [[property name] isEqualToString:[splits objectAtIndex:2]]){
                                    if( m.getArgType(0) == OFXOSC_TYPE_INT32){
                                        [property setIntValue:m.getArgAsInt32(0)];
                                    } else if( m.getArgType(0) == OFXOSC_TYPE_FLOAT){
                                        [property setFloatValue:m.getArgAsFloat(0)];
                                    } else {
                                        NSLog(@"Unknown osc format");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}



- (oscTrackerData) getTracker:(int)tracker{
    if(tracker >= 0 && tracker < 10){
        return trackerData[tracker];
    }
    return oscTrackerData();
}

- (vector<ofVec2f>) getTrackerCoordinates{
    vector<ofVec2f> v;
    for(int i=0;i<10;i++){
        if(trackerData[i].active){
            v.push_back(trackerData[i].point);
        }
    }
    return v;
}




@end


