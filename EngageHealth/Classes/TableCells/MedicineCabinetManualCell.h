//
//  MedicineCabinetManualCell.h
//  EngageHealth
//
//  Created by Nithin Nizam on 8/18/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MedicineCabinetDelegate.h"
#define AlarmButtonTagOffset 999


@interface MedicineCabinetManualCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *drugNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *alarmStatusButton;
@property (strong, nonatomic) id <MedicineCabinetDelegate>cellDelegate;
@property (strong, nonatomic) IBOutlet UIButton *deleteManualDrug;
@property (strong, nonatomic) IBOutlet UILabel *clockBgLabel;

- (IBAction)alarmStatusCheck:(id)sender;
@end
