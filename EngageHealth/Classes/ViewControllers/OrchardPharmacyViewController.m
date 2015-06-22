//
//  OrchardPharmacyViewController.m
//  Envisionrx
//
//  Created by Nassif on 31/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "OrchardPharmacyViewController.h"

@interface OrchardPharmacyViewController ()

@end

@implementation OrchardPharmacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Orchard Pharmacy";
    
    savingsViewConstraint.constant = 0;
    [savingsView layoutIfNeeded];
    
    savingsView.hidden = YES;
    
    if (self.showSavings) {
        savingsView.hidden = NO;
        drugName.text = self.selectedDrug[@"PRODDESCABBREV"];
        supplyPayLabel.text = [NSString stringWithFormat:@"Pay %0.2f for 90 days supply",[self.selectedDrug[@"Copay"] floatValue]];
        errorMessageLabel.text = self.selectedDrug[@"errorMessage"];
        errorMessageLabel.hidden = [self.selectedDrug[@"errorMessage"] length] == 0 ? YES : NO;
        savingsLabel.hidden = [self.selectedDrug[@"hasSavings"] length] == 0 ? YES : NO;
        savingsLabel.backgroundColor  = [self.selectedDrug[@"save"] floatValue] < 0.0 ? Saving_Red :GREEN_COLOR;
        savingsLabel.attributedText = [self attributedTextForPricingText:[NSString stringWithFormat:@"%0.2f",[self.selectedDrug[@"save"] floatValue]] ];
        
        
        savingsViewConstraint.constant = [savingsView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    orchardPharmacyHeaderOriginConstraint.constant = savingsViewConstraint.constant + 8;
  //  if ([self pharmacyHasOperationHours] == NO) {
      //  self.operationHoursHeightConstraint.constant = 0;
        hoursLabel.text = @"Mon - 9 a.m to 5 p.m \nTue - 9 a.m to 5 p.m\nWed - 9 a.m to 5 p.m\nThu - 9 a.m to 5 p.m\nFri - 9 a.m to 5 p.m\nSat - 9 a.m to 5 p.m\nSun - 9 a.m to 5 p.m";
   // }

    [savingsView layoutIfNeeded];
    [savingsView updateConstraints];
    [self.view updateConstraints];
    
    // Do any additional setup after loading the view.
}

- (NSAttributedString*)attributedTextForPricingText:(NSString*)pricingValue  {
    
    NSString *mainString = @"";
    
    float saveValue = [pricingValue floatValue];
    int savingsValue = (int)roundf(saveValue);
    
    if(saveValue < 0.0) {
        mainString = [NSString stringWithFormat:@"$%@\nmore\nper year",[EHHelpers commmaSeparatedStringForDigit:savingsValue*-1]];
        savingsValue = savingsValue*-1;
    }
    else{
        mainString = [NSString stringWithFormat:@"Save\n$%@\nper year",[EHHelpers commmaSeparatedStringForDigit:savingsValue]];
    }
    
    NSRange subTextRange = [mainString rangeOfString:[NSString stringWithFormat:@"$%@",[EHHelpers commmaSeparatedStringForDigit:savingsValue]]];
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:mainString];
    NSInteger stringLength=[mainString length];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange( 0,subTextRange.location )];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_BOLD size:18]
                      range:NSMakeRange(subTextRange.location, subTextRange.length)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange(subTextRange.location + subTextRange.length, stringLength - (subTextRange.location + subTextRange.length) )];
    
    [attString addAttribute:NSForegroundColorAttributeName value: Saving_White range:NSMakeRange(0, stringLength)];
    return attString;
    
}


#pragma mark
// Operation Hours of a pharmacy
- (NSString*)operationalHoursOfPharmacy:(NSDictionary*)pharmacyDetail {
    
    NSString *operationHrs = [NSString stringWithFormat:@"Mon - %@\nTue - %@\nWed - %@\nThu - %@\nFri - %@\nSat - %@\nSun - %@",pharmacyDetail[@"monHrs"],pharmacyDetail[@"tueHrs"],pharmacyDetail[@"wedHrs"],pharmacyDetail[@"thuHrs"],pharmacyDetail[@"friHrs"],pharmacyDetail[@"satHrs"],pharmacyDetail[@"sunHrs"]];
    return operationHrs;
}


#pragma mark
// Check if the pharmacy has operation hour details
- (BOOL)pharmacyHasOperationHours {
    
    NSArray *hours = @[@"monHrs",@"tueHrs",@"wedHrs",@"thuHrs",@"friHrs",@"satHrs",@"sunHrs"];
    NSMutableArray *opnHrs = [NSMutableArray array];
    /*
    for (NSString *hourKey in  hours) {
        
        NSString *operationHour = self.pharmacyDetail[hourKey];
        if ([operationHour rangeOfString:@"N/A"].location == NSNotFound) {
            [opnHrs addObject:@"1"];
        }
    }*/
    return [opnHrs count] > 0 ? YES : NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openUrl:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.orchardrx.com/en/registration.aspx"]];
}

- (IBAction)makeCall:(id)sender {
    
    [EHHelpers registerGAWithCategory:@"Mail Order Pharmacy" forAction:@"Call Orchard Pharmacy"];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",OrchardPharmacyNumber]];
    [[UIApplication sharedApplication] openURL:phoneUrl];
}

- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark Custom PopUp (Vaccine/Retailer)
// Hide the Custom Pop Up Alerts
- (IBAction)hidePopUpView:(id)sender {
    
    popUpView.hidden = YES;
}


// Shows the retailer's day supply alert
- (IBAction)showDaySupplyAlert:(id)sender {
    
    popUpView.hidden = NO;
}

@end
