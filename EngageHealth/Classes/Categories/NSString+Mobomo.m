//
//  NSString+Mobomo.m
//  Efiia
//
//  Created by John Cromartie on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+Mobomo.h"

static NSString *URLBadChars = @"!*\"'();:@&=+$,./?%#[]";

@implementation NSString (Mobomo)

- (NSString *)stringByActuallyAddingURLEncoding {
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL,
																(__bridge CFStringRef)URLBadChars,
																kCFStringEncodingUTF8);
}

@end
