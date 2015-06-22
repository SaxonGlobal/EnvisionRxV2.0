//
//  LoadingView.h
//  Envisionrx
//
//  Created by Nassif on 07/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int originConstant;

@interface LoadingView : UIView {
    
    IBOutlet UIView *redCircle,*greenCircle,*yellowCircle;
}
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *RedCircleCenterConstraint,*greenCircleCenterConstraint;

- (void)animateLoading;
- (void)reverseAnimation;
- (void)startAnimations;
- (void)clearAllAnimations;
@end
