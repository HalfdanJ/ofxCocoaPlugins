#import "OpenDMX.h"

#import <ola/DmxBuffer.h>
#import <ola/SimpleClient.h>

//using namespace ola;

ola::SimpleClient * simpleClient;
ola::OlaClient *client;
ola::DmxBuffer *buffer;

@implementation OpenDMX

@synthesize dmxData;

-(void)initPlugin{
        
    simpleClient = new ola::SimpleClient();
	connected = simpleClient->Setup();
	if (!connected) {
		cout<<"Failed getting OLA server"<<endl;
	}
	
	client = simpleClient->GetClient();
    
    buffer = new ola::DmxBuffer();
    
    dmxData = [NSMutableArray arrayWithCapacity:512];
    for(int i=0;i<512;i++){
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i],@"channel", [NSNumber numberWithInt:0],@"value", nil];
        [dict addObserver:self forKeyPath:@"value" options:nil context:@"value"];
        [dmxData addObject:dict];
    }
	
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*)context isEqualToString:@"value"]){
        int val = [[object valueForKey:@"value"] intValue];
        int channel = [[object valueForKey:@"channel"] intValue];
        buffer->SetChannel(channel, val);
    }
}

-(void) setValue:(int)val forChannel:(int)channel{
    //buffer->SetChannel(channel, val);
    [[dmxData objectAtIndex:channel] setObject:[NSNumber numberWithInt:val] forKey:@"value"];
}

//
//----------------
//


-(void)setup{
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    unsigned int universe = 0;
    if (!client->SendDmx(universe, *buffer)) {
        
    }
    
    buffer->Blackout();
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

@end
