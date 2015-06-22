//
//  PharmacyCellTableViewCell.h
//  EngageHealth
//
//  Created by Nassif on 18/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PharmacyCellTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *pharmName;
@property (strong, nonatomic) IBOutlet UILabel *pharmaStreetLabel;
@property (strong, nonatomic) IBOutlet UILabel *pharmaDistance;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pharmacyOpenStatus;
@property (strong, nonatomic) IBOutlet UILabel *pharmTimeNA;

@end
