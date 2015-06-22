//
//  LoginViewController.h
//  cbs
//
//  Created by Nithin Nizam on 7/30/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationViewController.h"
#import "InfoAlert.h"
#import "LoginViewController.h"
#import "LoadingView.h"
#import "CustomHTMLPageView.h"
#import "User+DAO.h"
#import "EHOperation.h"
#import "NSString+Mobomo.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


enum {
    UserNameField = 1000,
    PasswordField = 1001
}TextBox;
@interface LoginViewController : GAITrackedViewController <UITextFieldDelegate,RegistrationDelegate,EHOperationProtocol> {
    
    IBOutlet UITextField *userNameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet UIView *rememberView;
    LoadingView *customLoadingView;
    IBOutlet UIButton *forgotYourPasswordButton,*loginButton,*helpLineButton, *rememberButton;
    BOOL isForgotOptionsSelected;
}
@property (nonatomic ,strong) UITextField *activeField;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *forgotPasswordOriginContraint;

- (IBAction)signInButtonPressed;
- (IBAction)forgotPasswordPressed;
- (IBAction)signupNewUser:(id)sender;
- (IBAction)hideKeyBoard:(id)sender;
- (IBAction)activateLoginField:(id)sender;
- (IBAction)callHelpLine:(id)sender;
- (IBAction)rememberLogin;
@end
