#import "PluginEnabledCell.h"


@implementation PluginEnabledCell
-(void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	if([self isEditable]){	
		[super drawWithFrame:cellFrame inView:controlView];
	}
}
@end
