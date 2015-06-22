//
//  AlarmCell.m
//  EngageHealth
//
//  Created by Nassif on 19/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AlarmCell.h"

@implementation AlarmCell
@synthesize timeLabel;
@synthesize timeStatusLabel;
@synthesize alarmSwitch;
@synthesize repeatLabel;
@synthesize rightArrow;
@synthesize deleteButton;
@synthesize timeXOriginConstraint;
@synthesize editingOptionsButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
