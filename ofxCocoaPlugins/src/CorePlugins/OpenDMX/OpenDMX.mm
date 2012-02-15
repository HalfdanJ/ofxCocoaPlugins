#import "OpenDMX.h"

#import <ola/DmxBuffer.h>
//#import <ola/SimpleClient.h>
#include <ola/StreamingClient.h>
#include <ola/Logging.h>

//using namespace ola;

ola::StreamingClient  simpleClient;
//ola::OlaClient *client;
ola::DmxBuffer buffer;

@implementation OpenDMX

@synthesize dmxData;

-(void)initPlugin{
    ola::InitLogging(ola::OLA_LOG_WARN, ola::OLA_LOG_STDERR);
    
    //    simpleClient = new ola::StreamingClient();
	connected = simpleClient.Setup();
	if (!connected) {
		cout<<"Failed getting OLA server"<<endl;
	}
	
	//client = simpleClient->GetClient();
    
    //buffer = new ola::DmxBuffer();
    buffer.Blackout();
   
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
        //   buffer->SetChannel(channel, val);
        [self setValue:val forChannel:channel];
    }
}

-(void) setValue:(int)val forChannel:(int)channel{
    dispatch_async(dispatch_get_main_queue(), ^{
        
       // if(buffer.Get(channel) != val){
//            buffer.SetChannel(channel, val)//;
        buffer.SetRangeToValue(channel-1, val, 1);
        //}
       // buffer.SetRangeToValue(0, 255, 25);
    });
    // [[dmxData objectAtIndex:channel] setObject:[NSNumber numberWithInt:val] forKey:@"value"];
}

//
//----------------
//


-(void)setup{
}

-(void)applicationWillTerminate:(NSNotification *)note{
    buffer.SetRangeToValue(0, 0, 512);
    simpleClient.SendDmx(0, buffer);
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    unsigned int universe = 0;
    // buffer->SetRangeToValue(0, 100, 20);
    if(connected){
        dispatch_async(dispatch_get_main_queue(), ^{

            if (!simpleClient.SendDmx(universe, buffer)) {
                NSLog(@"DMX ERROR");
            }
          //  buffer.SetRangeToValue(0, 255, 20);

        });
    }
    //buffer->Blackout();
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
