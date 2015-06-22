//
//  MedicineCabinetCell.h
//  EngageHealth
//
//  Created by Nithin Nizam on 7/23/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MedicineCabinetDelegate.h"

#define AlarmButtonTagOffset 999

@interface MedicineCabinetCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *drugNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *drugAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *daysLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *savingsLabel;

@property (strong, nonatomic) IBOutlet UIButton *alarmStatusButton;
@property (strong ,nonatomic) IBOutlet UIButton *savingButton;
@property (strong, nonatomic) IBOutlet UIButton *renewRefillButton;

@property (strong, nonatomic) IBOutlet UIView *refillNormalView,*refillAlertView,*refillWarningView;
@property (strong, nonatomic) IBOutlet UILabel *refillNormalDaysLeft,*refillAlertDaysLeft;

@property (strong, nonatomic) id <MedicineCabinetDelegate>cellDelegate;
- (IBAction)alarmStatusCheck:(id)sender;

@end
