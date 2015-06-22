//
//  Created by Mobomo LLC on 13/01/11.
//  Copyright 2011 Mobomo LLC. All rights reserved.
//

#import "EHWindow.h"


@implementation EHWindow

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	return self;
}
#pragma mark activity timer


- (void)sendEvent:(UIEvent *)event {
	[super sendEvent:event];
	[[NSUserDefaults standardUserDefaults] setObject:[EHHelpers stringFromDate:[NSDate date] format:kDefaultDateFormat]  forKey:@"timeOfLastActivity"];
	[[NSUserDefaults standardUserDefaults] synchronize];  
    
}



@end
