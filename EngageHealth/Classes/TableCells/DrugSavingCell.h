//
//  DrugSavingCell.h
//  EngageHealth
//
//  Created by Nassif on 26/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrugSavingCell : UITableViewCell


@property (nonatomic ,strong) IBOutlet UILabel *drugTitle;
@property (nonatomic ,strong) IBOutlet UIView *savingContainerView;
@property (nonatomic ,strong) IBOutlet UIImageView *rightArrow;
@property (nonatomic ,strong) IBOutlet UIButton *detailedSavingsButton;
@property (nonatomic ,strong) IBOutlet UILabel *SavingsLabel;
@property (nonatomic ,strong) IBOutlet UILabel *noPricingErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end
