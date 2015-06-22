//
//  MedicineCabinetManualCell.m
//  EngageHealth
//
//  Created by Nithin Nizam on 8/18/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MedicineCabinetManualCell.h"

@implementation MedicineCabinetManualCell

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

- (IBAction)deleteDrug:(id)sender {
    [self.cellDelegate deleteDrug:(int)[sender tag] - AlarmButtonTagOffset];

}
@end
