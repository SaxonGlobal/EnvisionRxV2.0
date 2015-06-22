//
//  SettingsViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 8/7/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIViewController+AMSlideMenu.h"

@interface SettingsViewController  ()
@property (nonatomic ,strong) EHOperation *networkOperation;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"My Profiles";
    settingsUpdated = NO;
    changePasswordView.hidden = YES;
    zipCodeEditView.hidden = YES;
    termsOriginConstraint.constant = self.view.frame.size.height;
    termsHeightConstraint.constant = self.view.frame.size.height;
    customPageView.contentType = TermsAndCondition;
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [self initialiseLoadingView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deactivateKeyBoard) name:@"OpenLeftMenuNotification" object:nil];
    
    [self addNotificationListeneForKeyBoard];
    [self customizeSlider:pharmacyRadiusSlider];
    [self customizeSlider:noOfMonthsSlider];
    [self customizeSlider:noOfPharmacySlider];
    
    [self underlineText:changePasswordButton withString:@"CHANGE PASSWORD"];
    [self underlineText:saveZipCodeButton withString:@"EDIT"];
    [self underlineText:termsButton withString:@"Read full terms and conditions"];
    [self loadProfileDetails];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if (settingsUpdated == YES) {
        [EHHelpers registerGAWithCategory:@"Profile Settings" forAction:@"Settings Update"];
    }
    [self saveUserDefaultSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deactivateKeyBoard {
    [self.activeField resignFirstResponder];
}
#pragma mark
#pragma mark Loading Screen

// Initialise the custom loading view
- (void)initialiseLoadingView {
    
    customLoadingView = [[LoadingView alloc] init];
    customLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
}

// Show loading screen
- (void)showLoadingView {
    
    [self.view addSubview:customLoadingView];
    NSDictionary *views = NSDictionaryOfVariableBindings(customLoadingView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customLoadingView]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[customLoadingView]|" options:0  metrics:nil views:views]];
    [self.view updateConstraints];
    [customLoadingView performSelector:@selector(startAnimations) withObject:nil afterDelay:0.2];
    
}

#pragma mark
#pragma TermsAndCondition

- (IBAction)showTerms:(id)sender{
    
    [self.activeField resignFirstResponder];
    termsOriginConstraint.constant = 0;
    [self.view updateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        
        
    } completion:nil];
    [customPageView loadHTMLData];
}

- (IBAction)cancelTermsView:(id)sender {
    
    termsOriginConstraint.constant = self.view.frame.size.height;
    [self.view updateConstraints];
    [customPageView cancel];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}



#pragma mark 
#pragma mark Default Settings

- (void)loadProfileDetails {
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        
        firstName.text = currentuser.firstName;
        lastName.text = currentuser.lastName;
        dob.text = currentuser.dob;
        gender.text = (currentuser.gender.intValue == 77 )? @"M" : @"F";
        memberId.text = currentuser.memberId;
        relationship.text = [self textForId:currentuser.relationId.intValue forArrayList:RelationList];
        email.text = currentuser.email;
        password.text = [self appendSecurePassword:currentuser.password];
        securityQuestion.text = [self textForId:currentuser.questionId.intValue forArrayList:[APP_DELEGATE securityQuestions]];
        securityAnswer.text = @"";
        zipCode.text = currentuser.zipCode;
    }
    [self loadDefaultRadiusSettings];
}

- (void)loadDefaultRadiusSettings {
    
    User *currentUser = [APP_DELEGATE currentUser];
    
    if (currentUser) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userKey = [NSString stringWithFormat:@"Profile-%@",currentUser.email];
        NSDictionary *settingsDict = ([defaults objectForKey:userKey] != nil ) ? [NSDictionary dictionaryWithDictionary:[defaults objectForKey:userKey]] : [NSDictionary dictionary];
        pharmacyRadius.text = settingsDict[@"radius"] != nil ?  [NSString stringWithFormat:@"%d",[settingsDict[@"radius"] intValue]]: [NSString stringWithFormat:@"%d",DefaultPharmacyRadius] ;
        
        noOfPharmacy.text = settingsDict[@"pharmacyCount"] != nil ? [NSString stringWithFormat:@"%d",[settingsDict[@"pharmacyCount"] intValue]]: [NSString stringWithFormat:@"%d",DefaultNumberOfPharmacy] ;
        
        noOfMonthsDisplayed.text = settingsDict[@"claimsInterval"] != nil ?  [NSString stringWithFormat:@"%d",[settingsDict[@"claimsInterval"] intValue]] : [NSString stringWithFormat:@"%d",DefaultClaimsInterval];
        zipCode.text = settingsDict[@"zipCode"] != nil ? settingsDict[@"zipCode"] : currentUser.zipCode;
        
    }
    else {
        pharmacyRadius.text = [NSString stringWithFormat:@"%d",DefaultPharmacyRadius] ;
        noOfPharmacy.text = [NSString stringWithFormat:@"%d",DefaultNumberOfPharmacy] ;
        noOfMonthsDisplayed.text = [NSString stringWithFormat:@"%d",DefaultClaimsInterval];
        
    }
    [self updateSliderCurrentValues:pharmacyRadiusSlider withValue:[pharmacyRadius.text floatValue]];
    [self updateSliderCurrentValues:noOfPharmacySlider withValue:[noOfPharmacy.text floatValue]];
    [self updateSliderCurrentValues:noOfMonthsSlider withValue:[noOfMonthsDisplayed.text floatValue]];
}

- (void)saveUserDefaultSettings {
    
    User *currentUser = [APP_DELEGATE currentUser];
    if (currentUser) {
        
        NSString *userKey = [NSString stringWithFormat:@"Profile-%@",currentUser.email];
        NSMutableDictionary *settingsDict = [NSMutableDictionary dictionary];
        
        settingsDict[@"radius"] = [NSNumber numberWithInt:[pharmacyRadius.text intValue]];
        settingsDict[@"pharmacyCount"] = [NSNumber numberWithInt:[noOfPharmacy.text intValue]];
        settingsDict[@"claimsInterval"] = [NSNumber numberWithInt:[noOfMonthsDisplayed.text intValue]];
        settingsDict[@"zipCode"] = zipCode.text;
        [EHHelpers syncDefaults:userKey dataToSync:settingsDict];
    }
}

#pragma mark

// Make password secure text
- (NSString*)appendSecurePassword:(NSString*)securePassword {
    NSUInteger count = 0, length = [securePassword length];
    
    NSMutableString *secureString = [NSMutableString string];
    
    while (count < length) {
        count++;
        [secureString appendString:@"*"];
    }
    return secureString;
}

#pragma mark
#pragma Slider Settings

// Apply custom tracking images for the slider
- (void)customizeSlider:(UISlider*)slider {
    
    [slider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateSelected];
    [slider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateHighlighted];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"white_slider_bar"] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"green_slider_bar"] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[[UIImage imageNamed:@"green_slider_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]  forState:UIControlStateNormal];
}

- (void)updateSliderCurrentValues:(UISlider*)slider withValue :(float)sliderValue {
    
    slider.value = sliderValue;
    
    
}
- (IBAction)sliderValueChange:(id)sender {
    
    settingsUpdated = YES;
    UISlider *slider = (UISlider*)sender;
    NSString *sliderValue = [NSString stringWithFormat:@"%d", (int)[slider value]];
    switch (slider.tag) {
        case PharmacyRadius:
            pharmacyRadius.text = sliderValue ;
            break;
        case MinimumClaimsInterval:
            noOfMonthsDisplayed.text = sliderValue ;
            break;
        case MinimumPharmacy:
            noOfPharmacy.text = sliderValue ;
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark KeyBoardNotificationListener

// Notification Handler for keyboard
- (void)addNotificationListeneForKeyBoard {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

//  Notification handler while keyboard is shown
- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    float heightOrigin = 0;
    
    if (([self.activeField tag] == 2000)) {
        
        heightOrigin =  fmaxf(0,self.activeField.frame.origin.y - 100 );
        self.keyBoardOptionsConstant.constant = -44 ;
        
    }
    else {
        heightOrigin =   self.activeField.superview.frame.origin.y - 100 ;
        self.keyBoardOptionsConstant.constant = kbRect.size.height ;
    }
    [self.view updateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        UIScrollView *scrollContainer = [self.activeField tag] == 2000 ? changePasswordScrollView : profileScrollView ;
        scrollContainer.contentOffset = CGPointMake(0, heightOrigin);
    } completion:nil];
    
}

// Keyboard notifications actions : On hidden

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.changePasswordScreenOriginConstraint.constant = 0;
    [self.view updateConstraints];
    
    [UIView animateWithDuration:1.0 animations:^{
        
        profileScrollView.contentInset = contentInsets;
        profileScrollView.scrollIndicatorInsets = contentInsets;
        changePasswordScrollView.contentOffset = CGPointZero;
        [self.view layoutIfNeeded];
        
        
    } completion:nil];
    
}

#pragma mark

- (NSString*)textForId:(int)relationID forArrayList:(NSArray*)arrayList{
    
    NSString *relationString = arrayList[0][@"text"];
    NSArray *filteredArray = [arrayList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id.intValue == %d",relationID]];
    if ([filteredArray count] > 0) {
        relationString = filteredArray[0][@"text"];
    }
    
    return relationString;
}

#pragma mark

// Underline the button text
- (void)underlineText:(UIButton*)callButton withString:(NSString*)numberString {
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:numberString];
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:1.0] range:NSMakeRange(0, [commentString length])];
    [callButton setAttributedTitle:commentString forState:UIControlStateNormal];
}



#pragma mark
#pragma mark ZipCode Editing

- (IBAction)saveZipCode:(id)sender{
    
    if ([zipCodeTextField.text length] == 0 || [zipCodeTextField.text length] < 5) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter a valid zip code." delegate:nil];
    }
    else{
        settingsUpdated = YES;
        zipCodeEditView.hidden = YES;
        zipCode.text = zipCodeTextField.text;
        [zipCodeTextField resignFirstResponder];
        saveZipCodeButton.hidden = NO;
        zipCodeKeyBoardOptionsView.hidden = YES;
        self.keyBoardOptionsConstant.constant = -44;
        
        [self underlineText:saveZipCodeButton withString:@"EDIT"];
        [self saveUserDefaultSettings];
    }
}

- (IBAction)changeZipCode:(id)sender {
    
    UIButton *zipCodeButton = (UIButton*)sender;
    zipCodeButton.selected = !zipCodeButton.selected;
    
    if (zipCodeButton.selected == YES) {
        
        zipCodeEditView.hidden = NO;
        [zipCodeTextField becomeFirstResponder];
        saveZipCodeButton.hidden = YES;
        zipCodeKeyBoardOptionsView.alpha = 0.0;
        zipCodeKeyBoardOptionsView.hidden = NO;
        [UIView animateWithDuration:2.0 animations:^{
            
            zipCodeKeyBoardOptionsView.alpha = 1.0;
        } completion:^(BOOL finished) {
            ;
        }];
    }
    else{
        [zipCodeTextField resignFirstResponder];
        zipCodeEditView.hidden = YES;
        saveZipCodeButton.hidden = NO;
        [self underlineText:saveZipCodeButton withString:@"EDIT"];
        zipCodeKeyBoardOptionsView.hidden = YES;
        self.keyBoardOptionsConstant.constant = -44;
        
        
    }
}

- (IBAction)cancelZipCodeEditing:(id)sender {
    
    [zipCodeTextField resignFirstResponder];
    zipCodeEditView.hidden = YES;
    [saveZipCodeButton setHidden:NO];
    zipCodeKeyBoardOptionsView.hidden = YES;
    self.keyBoardOptionsConstant.constant = -44;
    [self changeZipCode:saveZipCodeButton];
    
}

- (IBAction)makeKeyboardInactive:(id)sender {
    [self.activeField resignFirstResponder];
    
}

#pragma mark
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)sender
{
    self.activeField = sender;
}

- (void)textFieldDidEndEditing:(UITextField *)sender
{
    self.activeField = nil;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[contentScrollView setContentOffset:CGPointZero animated:YES];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1000 && string.length > 0 && textField.text.length >= 5)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}


#pragma mark -
#pragma mark IBActionMethods

- (IBAction)showMenu {
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}

#pragma mark
#pragma mark Change User Password

- (IBAction)showChangePasswordView {
    
    changePasswordView.hidden = NO;
}

- (IBAction)cancelPasswordChange:(id)sender {
    
    changePasswordView.hidden = YES;
    [changePasswordScrollView scrollsToTop];
    [self.activeField resignFirstResponder];
    [profileScrollView scrollsToTop];
    [self loadProfileDetails];
}

- (IBAction)changePassword {
    
    [self.activeField resignFirstResponder];
    User *currentuser = [APP_DELEGATE currentUser];
    
    
    if ([currentPassword.text length] > 0) {
        
        if (![currentPassword.text isEqualToString:currentuser.password]) {
            [EHHelpers showAlertWithTitle:@"" message:@"Incorrect current password, please try again." delegate:nil];
        }
        else if ([newPassword.text length] == 0) {
            [EHHelpers showAlertWithTitle:@"" message:@"You must enter your new password." delegate:nil];
            
        }
        else if ([EHHelpers validatePassword:newPassword.text] == NO){
            [EHHelpers showAlertWithTitle:@"" message:@"Password must contain at least 6 characters and 3 of the following 4 options: upper case, lower case, special character, and number." delegate:nil];
        }
        else if ([confirmPassword.text length] == 0) {
            if ([newPassword.text length] == 0) {
                [EHHelpers showAlertWithTitle:@"" message:@"You must enter your password." delegate:nil];
            }
            else{
                [EHHelpers showAlertWithTitle:@"" message:@"Confirm your password." delegate:nil];
                
            }
        }
        else if ([confirmPassword.text length] > 0 && [newPassword.text length] > 0 && (![newPassword.text isEqualToString:confirmPassword.text]) ){
            [EHHelpers showAlertWithTitle:@"" message:@"Your new password does not match the confirmation password. Please try again." delegate:nil];
        }
        else {
            // TO
            [self updateProfile];
        }
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your current password." delegate:nil];
        
    }
    
}

#pragma mark Profile API

- (IBAction)updateProfile {
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        NSString *soapAction = [NSString stringWithFormat:@"%@/UpdateMemberAccount", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHUpdateMemberAccount, currentuser.memberId, currentuser.personCode.intValue, currentuser.firstName, currentuser.lastName, currentuser.dob, currentuser.gender, currentuser.relationId.intValue, currentuser.groupId, currentuser.carrier, zipCodeTextField.text, currentuser.accountId.intValue, currentuser.guid, [newPassword.text stringByActuallyAddingURLEncoding], currentuser.email, currentuser.phone, currentuser.question, currentuser.questionId.intValue, @"", currentuser.pharmacy, currentuser.pharmacyName, currentuser.chainCode, currentuser.bin, currentuser.pcn, currentuser.memberHelp, currentuser.pharmacyHelp, currentuser.logoUrl, currentuser.mailOrderId.intValue, currentuser.mailOrderNABP.intValue, currentuser.houseHoldFlag.boolValue, currentuser.enabled.boolValue, currentuser.sso.boolValue, AppID];
        
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2,  soapBodyXML];
        
        [self showLoadingView];
        [self.networkOperation updateUserProfileWithBody:soapBody forAction:soapAction];
        
    }
    else{
        
        [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
        [self logOutUser];
    }
}

// Profile API response delegate
- (void)successfullyUpdatedUserProfile:(NSArray *)data {
    
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    
    
    if (data!= nil) {
        
        [EHHelpers registerGAWithCategory:@"New Password" forAction:@"New Password"];

        DDXMLElement *login = data[0];
        
        [User loginUserWithInfo:login withUserEmail:email.text withPassword:newPassword.text];
        [self cancelPasswordChange:nil];
        [EHHelpers showAlertWithTitle:@"" message:@"Your password has been successfully changed." delegate:nil];
        
    }
    else {
        [EHHelpers showAlertWithTitle:@"" message:@"Unable to connect to server." delegate:nil];
    }
}

- (void)error:(NSError *)operationError {
    
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
        if ([errorMessage isEqualToString:@"Invalid GUID. Please log in again"]) {
            [self logOutUser];
        }
    }
    
    
}
- (void)logOutUser {
    
    [APP_DELEGATE setCurrentUser:nil];
    [APP_DELEGATE stopSessionTimer];
    
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC.leftMenu performSegueWithIdentifier:@"showMedicineCabinetSegue" sender:nil];
}

@end
