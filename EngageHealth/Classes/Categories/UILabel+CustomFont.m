//
//  UILabel+CustomFont.m
//  cbs
//
//  Created by Nithin Nizam on 7/31/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import "UILabel+CustomFont.h"

@implementation UILabel (CustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end
