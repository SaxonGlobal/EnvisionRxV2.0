//
//  MedicineCabinetCell.m
//  EngageHealth
//
//  Created by Nithin Nizam on 7/23/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MedicineCabinetCell.h"

@implementation MedicineCabinetCell

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

- (IBAction)alarmStatusCheck:(id)sender {
    [self.cellDelegate showAlarmsForDrugIndex:(int)[sender tag] - AlarmButtonTagOffset];
}

- (IBAction)showDrugInfo:(id)sender {
    [self.cellDelegate showDrugInfo:(int)[sender tag] - AlarmButtonTagOffset];
}

- (IBAction)renewRefill:(id)sender {
    [self.cellDelegate drugRenewalRefill:(int)[sender tag] - AlarmButtonTagOffset];
}

@end
