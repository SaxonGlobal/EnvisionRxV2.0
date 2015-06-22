//
//  LoadingView.m
//  Envisionrx
//
//  Created by Nassif on 07/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "LoadingView.h"

int originConstant = 35;

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:nil options:nil];
        self = [nib objectAtIndex:0];
        [self setFrame:frame];
    }
    self.frame = frame;
    
    redCircle.layer.cornerRadius = 10.0;
    yellowCircle.layer.cornerRadius = 10.0;
    greenCircle.layer.cornerRadius = 10.0;
    
    
    return self;
}

- (void)startAnimations {
    
    [self animateLoading];
    
}
- (void)animateLoading {
    
    self.RedCircleCenterConstraint.constant = -originConstant;
    self.greenCircleCenterConstraint.constant = originConstant;
    [self updateConstraints];
    [self setNeedsUpdateConstraints];

    [UIView animateWithDuration:1.5 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self reverseAnimation];
    }];
    
}
- (void)reverseAnimation {
    
    self.RedCircleCenterConstraint.constant = originConstant;
    self.greenCircleCenterConstraint.constant = -originConstant;
    [self updateConstraints];
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:1.5 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self animateLoading] ;
    }];
    
}
- (void)clearAllAnimations {
    
    [self.layer removeAllAnimations];
    [self layoutSubviews];

}
@end
