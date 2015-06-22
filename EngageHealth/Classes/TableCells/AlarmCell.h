//
//  AlarmCell.h
//  EngageHealth
//
//  Created by Nassif on 19/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmCell : UITableViewCell


@property (nonatomic ,strong) IBOutlet UILabel *timeLabel;
@property (nonatomic ,strong) IBOutlet UILabel *timeStatusLabel;
@property (nonatomic ,strong) IBOutlet UILabel *repeatLabel;
@property (nonatomic ,strong) IBOutlet UISwitch *alarmSwitch;
@property (nonatomic ,strong) IBOutlet UIImageView *rightArrow;
@property (nonatomic ,strong) IBOutlet UIButton *deleteButton;
@property (nonatomic ,strong) IBOutlet UIButton *editingOptionsButton;

@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *timeXOriginConstraint;

@end
