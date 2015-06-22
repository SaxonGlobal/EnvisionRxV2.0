//
//  RenewRefillViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 8/29/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoAlert.h"
#import "PharmacyDetailViewController.h"
#import "Pharmacy.h"
#import "GAITrackedViewController.h"


#define LightGreen [UIColor colorWithRed:85.0/255.0 green:169.0/255.0 blue:78.0/255.0 alpha:1.0]
#define OverLayGreen [UIColor colorWithRed:67.0/255.0 green:132.0/255.0 blue:63.0/255.0 alpha:1.0]

#define LightAsh [UIColor colorWithRed:210.0/255.0 green:212.0/255.0 blue:201.0/255.0 alpha:1.0]
#define OverLayAsh [UIColor colorWithRed:181.0/255.0 green:182.0/255.0 blue:168.0/255.0 alpha:1.0]

@interface RenewRefillViewController : GAITrackedViewController<EHOperationProtocol> {
    
    IBOutlet UILabel *daysCountLable;
    IBOutlet UILabel *drugNameLabel;
    IBOutlet UILabel *fillDateLabel;
    IBOutlet UILabel *drugSavingsLabel;
    IBOutlet UILabel *savingsLabel;
    IBOutlet UILabel *pharmacyNameLabel;
    IBOutlet UILabel *pharmacyAddrLabel;
    IBOutlet UILabel *rxIdLabel;
    IBOutlet UILabel *daysLeftLabel;
    IBOutlet UILabel *refillStatusBgLabel;
    IBOutlet UIImageView *refillAlertImageView;
    IBOutlet UILabel *navTitleLabel;
    
}

@property (nonatomic, strong) id drugInfo;
@property (nonatomic, strong) NSMutableDictionary *pharmacyDetails;
@property (nonatomic ,strong) EHOperation *networkOperation;

- (IBAction)goBack;
- (IBAction)callPharmacy;

- (IBAction)showPharmacyDetails:(id)sender;
- (IBAction)showSavings:(id)sender;

@end
