
#import "KeystoneSurface.h"
#import "Keystoner.h"


@implementation KeystoneSurface
@synthesize name, visible, aspect, minAspectValue, maxAspectValue, cornerPositions, viewNumber, projectorNumber,softedgePart, softedgeTotalParts, warp, handleOffset;

-(id) init{
	if([super init]){
		
		[self setMinAspectValue:0.1];
		[self setMaxAspectValue:10];
		[self setAspect:[NSNumber numberWithInt:1]];
		[self setVisible:YES];
		[self setSoftedgePart:1];
		[self setSoftedgeTotalParts:1];
        [self setHandleOffsetWithoutRecalculation:1.0];
		
		[self resetCorners];
		
		warp = new Warp();
		coordWarp = new  coordWarping();
		
		[self recalculate];
		
		[self addObserver:self forKeyPath:@"cornerPositions" options:nil context:@"cornerPositions"];
		[self addObserver:self forKeyPath:@"viewNumber" options:nil context:@"viewNumber"];
		[self addObserver:self forKeyPath:@"projectorNumber" options:nil context:@"projectorNumber"];
	}
	return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"cornerPositions"]){
		[self recalculate];
	}
	if([(NSString*)context isEqualToString:@"viewNumber"]){
		[self recalculate];
	}
	if([(NSString*)context isEqualToString:@"projectorNumber"]){
		[self recalculate];
	}
}

-(void) recalculate{
	for(int i=0;i<4;i++){
		warp->SetCorner(i, [[[cornerPositions objectAtIndex:i] objectForKey:@"x"] floatValue], 1-[[[cornerPositions objectAtIndex:i] objectForKey:@"y"] floatValue]);
	}
	
	warp->MatrixCalculate();
	ofVec2f a[4];
	a[0] = ofVec2f(0,0);
	a[1] = ofVec2f(1,0);
	a[2] = ofVec2f(1,1);
	a[3] = ofVec2f(0,1);
	coordWarp->calculateMatrix(a, warp->corners);
	
}


-(void) resetCorners{
	NSMutableDictionary * dict0 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"x",[NSNumber numberWithInt:1], @"y", [NSNumber numberWithInt:0], @"num",nil];
	NSMutableDictionary * dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"x",[NSNumber numberWithInt:1], @"y", [NSNumber numberWithInt:1], @"num",nil];
	NSMutableDictionary * dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"x",[NSNumber numberWithInt:0], @"y", [NSNumber numberWithInt:2], @"num",nil];
	NSMutableDictionary * dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"x",[NSNumber numberWithInt:0], @"y", [NSNumber numberWithInt:3], @"num",nil];
	
	[self setCornerPositions:[NSMutableArray arrayWithObjects:dict0, dict1, dict2, dict3, nil]];
	
	[self setAspect:[NSNumber numberWithInt:1.0]];
	[self setVisible:YES];
	
}

-(IBAction) flipX{
	NSArray * cornerPos = [self cornerPositions];
	[self setCornerPositions:[NSMutableArray arrayWithObjects:[cornerPos objectAtIndex:1],[cornerPos objectAtIndex:0], [cornerPos objectAtIndex:3], [cornerPos objectAtIndex:2],nil]]; 
}

-(IBAction) flipY{
	NSArray * cornerPos = [self cornerPositions];
	[self setCornerPositions:[NSMutableArray arrayWithObjects:[cornerPos objectAtIndex:3],[cornerPos objectAtIndex:2], [cornerPos objectAtIndex:1], [cornerPos objectAtIndex:0],nil]]; 
}

-(void) setHandleOffsetWithoutRecalculation:(float)_offset{
    [self willChangeValueForKey:@"handleOffset"];
    handleOffset = _offset;
    [self didChangeValueForKey:@"handleOffset"];
    
}
-(void)setHandleOffset:(float)_handleOffset{
    handleOffset = _handleOffset;
    
    /*//Move handles
    float asp = [[self aspect] floatValue];
    ofVec2f center = ofVec2f(asp*0.5, 0.5);
    for(int i=0;i<4;i++){
        float x = [[[cornerPositions objectAtIndex:i] valueForKey:@"x"] floatValue];
        float y = [[[cornerPositions objectAtIndex:i] valueForKey:@"y"] floatValue];
        
        ofVec2f dir;
        switch (i) {
            case 0:
                dir = center*ofVec2f(-1,-1);
                break;
            case 1:
                dir = center*ofVec2f(1,-1);
                break;
            case 2:
                dir = center*ofVec2f(1,1);
                break;
            case 3:
                dir = center*ofVec2f(-1,1);
                break;
                
            default:
                break;
        }
        
        ofVec2f p = coordWarp->inversetransform((center+dir).x, (center+dir).y);
            
        cout<<"Set "<<i<<": "<<p.x<<" . "<<p.y<<"   was: "<<x<<" . "<<y<<"   ("<<(center+dir).x<<" . "<<(center+dir).y<<")"<<endl;
    }*/
    
    
}

-(void) drawGrid{
	[self drawGridSimple:NO];
}

-(void) drawGridSimple:(BOOL)simple{
	//ofPushStyle();
	glPushMatrix();{
		
		ofEnableAlphaBlending();
		string text = [name cStringUsingEncoding:NSUTF8StringEncoding ];
		float resolution = 14.0;
		float a = 1.0;
		bool drawBorder = true;
		float fontSize = 0.0025;
		
		/*int activeCorner = [[GetPlugin(Keystoner) trackingLayer] dragCorner];
		ofSetColor(255, 0, 0,255);
		ofFill();
		switch (activeCorner) {
			case 0:
				ofCircle(0, 0, 0.1);
				break;
			case 1:
				ofCircle([aspect floatValue], 0, 0.1);
				break;
			case 2:
				ofCircle([aspect floatValue], 1, 0.1);
				break;
			case 3:
				ofCircle(0, 1, 0.1);
				break;
			default:
				break;
		}
		*/
		ofSetLineWidth(1);
		ofSetColor(255, 255, 255, 255*a);
		int xNumber = resolution+floor(([aspect floatValue]-1)*resolution);
		int yNumber = resolution;
		
		for(int i=0;i<=yNumber;i++){
			ofLine(0, i*1.0/resolution, [aspect floatValue], i*1.0/resolution);
		}
		
		int xNumberCentered = xNumber;
		
		if (xNumber%2 == 1) {
			xNumberCentered--;
		}
		for(int i=0;i<=xNumberCentered;i++){
			ofLine(((i*1.0/resolution)-((xNumberCentered/resolution)*0.5))+(0.5*[aspect floatValue]), 0, ((i*1.0/resolution)-((xNumberCentered/resolution)*0.5))+(0.5*[aspect floatValue]), 1.0);
			
		}
		if(drawBorder){
			
			ofNoFill();
			ofSetLineWidth(1);
			
			ofSetColor(64, 128, 220,255*a);
			ofRect(0, 0, 1*[aspect floatValue], 1);
            
            if(handleOffset != 1.0){
                glPushMatrix();
                glTranslated([[self aspect] floatValue]*0.5, 0.5,0);
                glScaled(handleOffset,handleOffset,1.0);
                glTranslated(-[[self aspect] floatValue]*0.5, -0.5,0);
                
                ofSetColor(220, 128, 64,255*a);
                ofRect(0, 0, 1*[aspect floatValue], 1);
                
                glPopMatrix();
            }
			
			if(softedgeTotalParts > 1){
				ofSetColor(64, 128, 220,255*a);
				for(int i=0;i<softedgeTotalParts-1;i++){
					float x = (1+i)*[aspect floatValue] * 1.0/softedgeTotalParts;
					ofLine(x, 0, x, 1);
				}
			}
			
			ofFill();
			ofSetColor(255, 255, 255,255*a);
			ofSetLineWidth(1);
			
		} else {
			
			/*//white sides
			ofLine([aspect floatValue], 0, [aspect floatValue], 1);
			ofLine(0, 0, 0, 1);
			
			//yellow corners
			ofSetLineWidth(3);
			ofSetColor(255, 255,0,255*a);
			
			ofLine(0, 0, 0.05, 0.0);
			ofLine(0, 0, 0.0, 0.05);
			
			ofLine(0, 1, 0.05, 1);
			ofLine(0, 1, 0.0, 0.95);
			
			ofLine([aspect floatValue], 0, [aspect floatValue]-0.05, 0.0);
			ofLine([aspect floatValue], 0, [aspect floatValue], 0.05);
			
			ofLine([aspect floatValue], 1, [aspect floatValue]-0.05, 1.0);
			ofLine([aspect floatValue], 1, [aspect floatValue], 0.95);*/
			
		}
		
		if(!simple){
			
			//ofPushStyle();
			
			ofSetLineWidth(6);
			ofSetColor(255, 255,0,255*a);
			
			ofFill();
			
			//up arrow
			glBegin(GL_POLYGON);{
				glVertex2f(([aspect floatValue]*0.5), 0);
				glVertex2f(([aspect floatValue]*0.5)-(0.05), 1.0/resolution);
				glVertex2f(([aspect floatValue]*0.5)+(0.05), 1.0/resolution);
				glVertex2f(([aspect floatValue]*0.5), 0);		
			} glEnd();
			
			ofSetColor(0,0,0,255*a);
			
			glPushMatrix();{
				
				float fontSizeForN = fontSize * 0.40;
				
				glScaled(fontSizeForN, fontSizeForN, 1.0);
				
	//			glTranslated( [aspect floatValue]*0.5*1.0/fontSizeForN-[GetPlugin(Keystoner) font]->stringWidth("N")/1.5,  0.1*1.0/fontSizeForN-([GetPlugin(Keystoner) font]->stringHeight("N")*0.3), 0);	
				
	//			[GetPlugin(Keystoner) font]->drawString("N",0, 0);
				
			} glPopMatrix();
			
			ofSetColor(255, 255,0,255*a);
			
			ofNoFill();
			
			glBegin(GL_POLYGON);{
				
				glVertex2f(([aspect floatValue]*0.5)-(0.05), 1.0);
				glVertex2f(([aspect floatValue]*0.5), 1.0-(1.0/resolution));
				glVertex2f(([aspect floatValue]*0.5)+(0.05), 1.0);
				
			} glEnd();
			
			
			// center cross
			ofLine(([aspect floatValue]*0.5)-0.05, 0.5, ([aspect floatValue]*0.5)+0.05, 0.5);
			ofLine(([aspect floatValue]*0.5), 1.0/resolution, ([aspect floatValue]*0.5), 1.0-(0.5/resolution));
			
/*			glPushMatrix();{
				
				glScaled(fontSize, fontSize, 1.0);
				if([aspect floatValue] < 1.0){
				glTranslated( [aspect floatValue]*0.5*1.0/fontSize-([GetPlugin(Keystoner) recoilLogo]->getHeight()*0.4*[aspect floatValue]),  0.5*1.0/fontSize-([GetPlugin(Keystoner) recoilLogo]->getWidth()*[aspect floatValue])/2.0, 0);	
					glRotated(90, 0, 0, 1.0);
					glScaled([aspect floatValue], [aspect floatValue], 1.0);
				} else {
			//		glTranslated( [aspect floatValue]*0.5*1.0/fontSize-[GetPlugin(Keystoner) recoilLogo]->getWidth()/2.0,  0.5*1.0/fontSize+([GetPlugin(Keystoner) recoilLogo]->getHeight()*0.4), 0);	
				}
				ofFill();
				ofSetColor(255,255,255,255);
				[GetPlugin(Keystoner) recoilLogo]->draw([GetPlugin(Keystoner) recoilLogo]->getWidth()*0.20, [GetPlugin(Keystoner) recoilLogo]->getHeight()*0.2075, [GetPlugin(Keystoner) recoilLogo]->getWidth()*0.6,[GetPlugin(Keystoner) recoilLogo]->getHeight()*0.6);
			} glPopMatrix();*/
			
			// center elipse
			ofNoFill();
			ofSetCircleResolution(100);
			if([aspect floatValue] < 1.0){
				ofSetLineWidth(5);
				ofSetColor(64, 128, 220,255*a);
				for (float i = 1.35; i < 1.37; i+=0.01) {
					ofEllipse([aspect floatValue]/2, 0.5, [aspect floatValue]*i*(([aspect floatValue]/2)/[aspect floatValue]), [aspect floatValue]*i*0.5);
				}
			} else {
				ofSetLineWidth(5);
				ofSetColor(64, 128, 220,255*a);
				for (float i = 1.35; i < 1.37; i+=0.01) {
					ofEllipse([aspect floatValue]/2, 0.5,i*(([aspect floatValue]/2)/[aspect floatValue]), i*0.5);
				}
			}
			
			// text label
			ofSetLineWidth(1);
			
			//glTranslated( [aspect floatValue]*0.5*1/0.003-verdana.stringWidth(text)/2.0,  0.5*1/0.003+verdana.stringHeight(text)/2.0, 0);
			
			glPushMatrix();{
				glScaled(fontSize, fontSize, 1.0);
			/*	if([aspect floatValue] < 1.0){
				glTranslated( [aspect floatValue]*0.5*1.0/fontSize+([GetPlugin(Keystoner) font]->stringHeight(text)*0.3*[aspect floatValue]),  0.5*1.0/fontSize-([GetPlugin(Keystoner) font]->stringWidth(text)*[aspect floatValue])/2.0, 0);	
					glRotated(90, 0, 0, 1.0);
					glScaled([aspect floatValue], [aspect floatValue], 1.0);
				} else {
					glTranslated( [aspect floatValue]*0.5*1.0/fontSize-[GetPlugin(Keystoner) font]->stringWidth(text)/2.0,  0.5*1.0/fontSize-([GetPlugin(Keystoner) font]->stringHeight(text)*0.3), 0);	
				}
				ofSetColor(0, 0, 0,200);
				ofNoFill();
				ofSetLineWidth(6);
				[GetPlugin(Keystoner) font]->drawStringAsShapes(text,0,0);
				ofFill();
				ofSetColor(255, 255, 255,255);
				[GetPlugin(Keystoner) font]->drawStringAsShapes(text,0,0);*/
				ofSetLineWidth(1);
			} glPopMatrix();
			
		//	ofPopStyle();
			
		}
		
	} glPopMatrix();
	//ofPopStyle();
	ofFill();
}
-(void) apply{
	[self applyWithWidth:1.0 height:1.0];	
}
-(void) applyWithWidth:(float)width height:(float)height{
	float setW = 1.0/ ([[self aspect] floatValue]);
	float setH = 1.0;
	glScaled(width, height, 1.0);
	warp->MatrixMultiply();
	glScaled(setW, setH, 1.0);
    
    { //Handle offset
        glTranslated([[self aspect] floatValue]*0.5, 0.5,0);
        glScaled(1.0/handleOffset,1.0/handleOffset,1.0);
        glTranslated(-[[self aspect] floatValue]*0.5, -0.5,0);
    }
	if([self softedgeTotalParts] > 1){
		glScaled([self softedgeTotalParts], 1, 1.0);
		
		glTranslated(-([self softedgePart]-1)*([[self aspect] floatValue])/[self softedgeTotalParts], 0, 0);
	} 

}

-(void) setCornerPositions:(NSMutableArray *)a{
	
	[self willChangeValueForKey:@"cornerPositions"];
	if(cornerPositions != nil)
		[cornerPositions release];
	
	cornerPositions = [a retain];
	[self didChangeValueForKey:@"cornerPositions"];
}

-(ofVec2f) convertToProjection:(ofVec2f)p{
	p.x /= [aspect floatValue];
    
    if(handleOffset != 1.0){
        p += ofVec2f(-0.5,-0.5);
        p *= 1.0/handleOffset;
        p += ofVec2f(0.5,0.5);
    }
	ofVec2f r = (ofVec2f) coordWarp->transform(p.x, p.y);
	return r;
}

-(ofVec2f) convertFromProjection:(ofVec2f)p{
	ofVec2f r = coordWarp->inversetransform(p.x, p.y);
    
    if(handleOffset != 1.0){
        r += ofVec2f(-0.5,-0.5);
        r /= 1.0/handleOffset;
        r += ofVec2f(0.5,0.5);
    }
    
	r.x *= [aspect floatValue];
	//r.y = p.y;
	return r;
}


@end
