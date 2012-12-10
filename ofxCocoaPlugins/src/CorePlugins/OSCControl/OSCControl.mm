#import <ofxCocoaPlugins/OSCControl.h>
#import <ofxCocoaPlugins/Tracker.h>
#import <ofxCocoaPlugins/Keystoner.h>
#import <ofxCocoaPlugins/Midi.h>

NSString * SplitcapitalString(NSString *str)
{
    NSCharacterSet *cs = [NSCharacterSet uppercaseLetterCharacterSet];
    NSMutableString *result = [NSMutableString string];;
    if ([str length] == 0)
        return result;
    
    NSRange wordMatch, endMatch;
    wordMatch.location = 0;
    endMatch = [str rangeOfCharacterFromSet:cs
                                    options:0
                                      range:NSMakeRange(1, [str length] - 1)];
    while (endMatch.location != NSNotFound) {
        wordMatch.length = endMatch.location - wordMatch.location;
        [result appendFormat:@"%@ ", [str substringWithRange:wordMatch]];
//        [result addObject:[str substringWithRange:wordMatch]];
        wordMatch.location = endMatch.location;
        endMatch = [str rangeOfCharacterFromSet:cs
                                        options:0
                                          range:NSMakeRange(wordMatch.location + 1,
                                                            [str length] - wordMatch.location - 1)];
    }
    
    // add last word
    wordMatch.length = [str length] - wordMatch.location;
    //[result addObject:[str substringWithRange:wordMatch]];
    [result appendFormat:@"%@", [str substringWithRange:wordMatch]];

    return result;
}

@implementation OSCControl



- (id)init{
    self = [super init];
    if (self) {
        
        
        [self addPropB:@"generate"];
    }
    
    return self;
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
    
    [self generateInterface:NO];
    
}

//
//----------------
//



-(void) createInterface {
    {    
        ofxOscMessage m;
        m.setAddress( "/control/createBlankInterface" );    
        m.addStringArg( "ofxCocoaPlugins" );
        m.addStringArg( "portrait" );
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

- (void) addButton:(NSString*)name label:(NSString*)label labelSize:(int)labelSize bounds:(NSRect)bounds mode:(NSString*)mode sendIt:(BOOL)sendIt{
    if(sendIt)
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


-(void) addLabel:(NSString*)label labelSize:(int)labelSize bound:(NSRect) bounds align:(NSString*)align sendIt:(BOOL)sendIt{
        if(sendIt)
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     [label stringByReplacingOccurrencesOfString:@" " withString:@""], @"name",
                     label, @"value",
                     @"Label",@"type",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                     [NSString stringWithFormat:@"%i",labelSize], @"labelSize",
                     @"#ccc", @"color",
                     align, @"align",
                     nil]];
}

- (void) addButton:(NSString*)label labelSize:(int)labelSize bounds:(NSRect)bounds bindedTo:(PluginProperty*)property sendIt:(BOOL)sendIt{
    NSAssert(property, @"No property");
        if(sendIt)
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
    
    if(sendIt)
    [self setColor:[NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]] background:@"rgb(0,0,0)" foreground:@"rgb(80,100,80)" stroke:@"rgb(255,255,255)"];
}

- (void) addFader:(NSString*)label bounds:(NSRect)bounds bindedTo:(NumberProperty*)property sendIt:(BOOL)sendIt{
    NSAssert(property, @"No property");
        if(sendIt)
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]], @"name",
                     @"Slider",@"type",
                     [NSString stringWithFormat:@"/%@/%@",[property pluginName], [property name]], @"address",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                     [NSNumber numberWithFloat:property.minValue], @"min",
                     [NSNumber numberWithFloat:property.maxValue], @"max",
                     //     label, @"label",
                     nil]];
    [property addObserver:self forKeyPath:@"value" options:nil context:@"property"];
    
    if(sendIt)
    [self setColor:[NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]] background:@"rgb(0,0,0)" foreground:@"rgb(80,100,80)" stroke:@"rgb(255,255,255)"];
    
    [self sendProperty:property];
}

- (void) addKnob:(NSString*)label bounds:(NSRect)bounds bindedTo:(NumberProperty*)property sendIt:(BOOL)sendIt{
    NSAssert(property, @"No property");
    if(sendIt)
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]], @"name",
                     @"Knob",@"type",
                     [NSString stringWithFormat:@"/%@/%@",[property pluginName], [property name]], @"address",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"radius",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                     [NSNumber numberWithFloat:property.minValue], @"min",
                     [NSNumber numberWithFloat:property.maxValue], @"max",
                     //     label, @"label",
                     nil]];
    [property addObserver:self forKeyPath:@"value" options:nil context:@"property"];
    
    if(sendIt)
    [self setColor:[NSString stringWithFormat:@"%@_%@",[property pluginName], [property name]] background:@"rgb(0,0,0)" foreground:@"rgb(80,100,80)" stroke:@"rgb(255,255,255)"];
}

- (void) addMultiXY:(NSString*)name bounds:(NSRect)bounds isMomentary:(BOOL)isMomentary maxTouches:(int)maxTouches sendIt:(BOOL)sendIt{
    if(sendIt)
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     name, @"name",
                     @"MultiTouchXY",@"type",
                     [self rectToBoundsString:bounds], @"bounds",
                     [NSNumber numberWithBool:isMomentary], @"isMomentary",
                     [NSNumber numberWithBool:true], @"sendZValue",
                     [NSNumber numberWithInt:maxTouches], @"maxTouches",
                     nil]];
}

- (void) setColor:(NSString*)widget background:(NSString*)background foreground:(NSString*)foreground stroke:(NSString*)stroke  {
    
    ofxOscMessage m;
    m.setAddress( "/control/setColors" );    
    m.addStringArg( [widget cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [background cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [foreground cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [stroke cStringUsingEncoding:NSUTF8StringEncoding] );
    sender->sendMessage( m );
    
}

-(void) sendProperty:(NumberProperty*)object{
    ofxOscMessage msg;
    msg.setAddress([[NSString stringWithFormat:@"/%@/%@",[object pluginName], [object name]] cStringUsingEncoding:NSUTF8StringEncoding]);
    //     msg.setAddress("/menuButton");
    msg.addFloatArg([object floatValue]);
    
    sender->sendMessage(msg);

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*) context isEqualToString:@"property"]){
        if(sender != nil){
            [self sendProperty:object];
        }
    }
}




-(void) generateInterface:(BOOL)sendIt{
    if(sendIt)
        [self createInterface];
    
    
    for(NSDictionary * dict in [globalController plugins]){
        for(ofPlugin * plugin in [dict valueForKey:@"children"]){

            [plugin.properties enumerateKeysAndObjectsUsingBlock:^(id key, PluginProperty* obj, BOOL *stop) {
                float d = 0.1/8.0;
                for(int i=0;i<8;i++){
                    if([obj.midiChannel intValue] == 1 && [obj.midiNumber intValue] == i){
//                        NSLog(@"Bind %@",obj);
                        [self addFader:obj.name bounds:NSMakeRect(0, i*1.0/8.0+d, 0.125, 1.0/8.0-2*d) bindedTo:obj sendIt:sendIt];
                        [self addLabel:SplitcapitalString(obj.name) labelSize:12.0 bound:NSMakeRect(0.005, i*1.0/8.0+0.02, 0.123, 0.018) align:@"center" sendIt:sendIt];
                        
                        
                    }
                }
                
                for(int i=16;i<24;i++){
                    if([obj.midiChannel intValue] == 1 && [obj.midiNumber intValue] == i){
                        //                        NSLog(@"Bind %@",obj);
                        [self addFader:obj.name bounds:NSMakeRect(0.125, (i-16)*1.0/8.0+d, 0.125, 1.0/8.0-2*d) bindedTo:obj sendIt:sendIt];
                     //   [self addKnob:obj.name bounds:NSMakeRect(0, (i-16)*1.0/7.0+0.07, 0.08, 0.1) bindedTo:obj];
                        [self addLabel:SplitcapitalString(obj.name) labelSize:1.0 bound:NSMakeRect(0.129, (i-16)*1.0/8.0+0.02, 0.123, 0.018) align:@"center" sendIt:sendIt];
                        
                        
                    }
                }
            }];
        }
    }
    
    [self addMultiXY:@"trackerxy" bounds:NSMakeRect(0.25, 0.0, 0.75, .75) isMomentary:true maxTouches:3 sendIt:sendIt];
    if(sendIt)
        [self setColor:@"trackerxy" background:@"#000" foreground:@"#aaa" stroke:@"#ddd" ];
    
    //    [self addButton:@"but1" label:@"Tracker debug" labelSize:10 bounds:NSMakeRect(0.8, 0.0, 0.2, 0.1) mode:@"toggle"];

}
//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    if(PropB(@"generate")){
        SetPropB(@"generate", NO);
        //[self setup];
        [self generateInterface:YES];
        
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


