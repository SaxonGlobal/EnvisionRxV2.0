//
//  OrchardPharmacyViewController.h
//  Envisionrx
//
//  Created by Nassif on 31/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "Constants.h"

#define OrchardPharmacyNumber @"18669095170"

@interface OrchardPharmacyViewController : GAITrackedViewController {
    
    IBOutlet UILabel *drugName,*savingsLabel,*errorMessageLabel,*supplyPayLabel, *hoursLabel;
    IBOutlet NSLayoutConstraint *savingsViewConstraint,*orchardPharmacyHeaderOriginConstraint;
    IBOutlet UIView *savingsView, *operationHrsView, *popUpView;
}

@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *operationHoursHeightConstraint;
@property (nonatomic ,strong) NSDictionary *selectedDrug;
@property BOOL showSavings;

- (IBAction)openUrl:(id)sender;
- (IBAction)makeCall:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)hidePopUpView:(id)sender;
- (IBAction)showDaySupplyAlert:(id)sender;

@end
