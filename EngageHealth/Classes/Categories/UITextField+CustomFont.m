//
//  UITextField+CustomFont.m
//  cbs
//
//  Created by Nithin Nizam on 7/31/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import "UITextField+CustomFont.h"

@implementation UITextField (CustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

- (void)setLeftPadding:(int)paddingValue {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingValue, self.frame.size.height)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setRightPadding:(int)paddingValue {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingValue, self.frame.size.height)];
    self.rightView = paddingView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

@end
