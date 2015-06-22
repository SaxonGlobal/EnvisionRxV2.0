//
//  DetailedSavingCell.h
//  EngageHealth
//
//  Created by Nassif on 09/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedSavingCell : UITableViewCell


@property (nonatomic ,strong) IBOutlet UILabel *titleLabel,*addressLabel,*amountLabel,*distanceLabel,*supplyPayLabel;
@property (nonatomic ,strong) IBOutlet UIView *distanceView;
@property (nonatomic ,strong) IBOutlet UIButton *showPharmacyDetail;
@property (nonatomic ,strong) IBOutlet UILabel *noPricingMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *pharmacyTimeNA;
@property (strong, nonatomic) IBOutlet UIImageView *pharmacyOpenStatus;


@end
