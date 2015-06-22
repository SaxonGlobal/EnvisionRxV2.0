//
//  UIButton+CustomFont.m
//  cbs
//
//  Created by Nithin Nizam on 7/31/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import "UIButton+CustomFont.h"

@implementation UIButton (CustomFont)

- (NSString *)fontName {
    return self.titleLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}

@end
