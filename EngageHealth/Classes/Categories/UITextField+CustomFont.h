//
//  UITextField+CustomFont.h
//  cbs
//
//  Created by Nithin Nizam on 7/31/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (CustomFont)

@property (nonatomic, copy) NSString* fontName;

- (void)setLeftPadding:(int)paddingValue;
- (void)setRightPadding:(int)paddingValue;

@end
