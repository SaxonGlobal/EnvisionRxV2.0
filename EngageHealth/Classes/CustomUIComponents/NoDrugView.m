//
//  NoDrugView.m
//  Envisionrx
//
//  Created by Nassif on 23/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "NoDrugView.h"

@implementation NoDrugView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NoDrugView" owner:nil options:nil];
        self = [nib objectAtIndex:0];
        [self setFrame:frame];
    }
    self.frame = frame;
    return self;
}

@end
