//
//  SettingsViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 8/7/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHTMLPageView.h"
#import "User+DAO.h"
#import "Constants.h"
#import "NSString+Mobomo.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


enum {
    
    PharmacyRadius = 1000,
    MinimumPharmacy = 1001,
    MinimumClaimsInterval = 1002
};

#import "LoadingView.h"
#import "EHOperation.h"
@interface SettingsViewController : GAITrackedViewController <UITextFieldDelegate , EHOperationProtocol>{
    
    IBOutlet UILabel *firstName,*lastName,*dob,*gender,*memberId,*relationship,*email,*password,*securityQuestion,*securityAnswer,*zipCode,*pharmacyRadius,*noOfPharmacy,*noOfMonthsDisplayed;
    IBOutlet UIButton *changePasswordButton, *saveZipCodeButton;
    IBOutlet UISlider *pharmacyRadiusSlider,*noOfPharmacySlider,*noOfMonthsSlider;
    
    IBOutlet UIView *zipCodeEditView;
    IBOutlet UIView *changePasswordView;
    IBOutlet UITextField *zipCodeTextField,*newPassword,*confirmPassword,*currentPassword;
    IBOutlet UIScrollView *profileScrollView,*changePasswordScrollView;
    LoadingView *customLoadingView;
    IBOutlet UIView *zipCodeKeyBoardOptionsView;
    IBOutlet NSLayoutConstraint *termsOriginConstraint,*termsHeightConstraint;
    IBOutlet CustomHTMLPageView *customPageView;
    IBOutlet UIButton *termsButton;
    BOOL settingsUpdated;
}


@property BOOL isFromMedicineCabinet;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *changePasswordScreenOriginConstraint,*keyBoardOptionsConstant;
@property (weak, nonatomic) UITextField *activeField;

- (IBAction)showMenu;
- (IBAction)updateProfile;



- (IBAction)showChangePasswordView;
- (IBAction)changeZipCode:(id)sender;
- (IBAction)saveZipCode:(id)sender;
- (IBAction)cancelPasswordChange:(id)sender;
- (IBAction)changePassword;

- (IBAction)sliderValueChange:(id)sender;
- (IBAction)cancelZipCodeEditing:(id)sender ;
- (IBAction)makeKeyboardInactive:(id)sender;

@end
