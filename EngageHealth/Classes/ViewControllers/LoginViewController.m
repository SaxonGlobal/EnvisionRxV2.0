//
//  LoginViewController.m
//  cbs
//
//  Created by Nithin Nizam on 7/30/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import "LoginViewController.h"
#import "DDXML.h"
#import "User.h"

@interface LoginViewController ()
@property (nonatomic ,strong) EHOperation *networkOperation;
@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view.
    self.screenName = @"Login";
    
    
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [self initialiseLoadingView];
    self.forgotPasswordOriginContraint.constant = 81.0;
    isForgotOptionsSelected = NO;
    [forgotYourPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [EHHelpers underlineButtonText:forgotYourPasswordButton withString:@"Forgot your password?"];
    [EHHelpers underlineButtonText:helpLineButton withString:@"1-800-361-4542"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginUserSuccesful) name:@"kRegistrationSuccessFul" object:nil];
    
    NSString *user = @"";
    NSString *pass = @"";
    NSData *userData = [APP_DELEGATE searchKeychainCopyMatching:@"UserName"];
    if (userData) {
        user = [[NSString alloc] initWithData:userData
                                     encoding:NSUTF8StringEncoding];
        rememberButton.selected = YES;
    }
    
    userNameField.text = user;
    passwordField.text = pass;

}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Actions

- (IBAction)callHelpLine:(id)sender {
    
    NSString *phoneString = [helpLineButton.titleLabel.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@", phoneString];
    NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneStr]];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (IBAction)rememberLogin {
    rememberButton.selected = !rememberButton.selected;
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

// Show keyboard while tapping on the textbox
- (IBAction)activateLoginField:(id)sender {
    
    UIButton *textBoxButton = (UIButton*)sender;
    
    if (textBoxButton.tag == UserNameField) {
        [userNameField becomeFirstResponder];
    }
    else {
        [passwordField becomeFirstResponder];
    }
}


#pragma mark
#pragma mark TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.activeField = textField;
    float offset = (textField == userNameField ) ? 50 : 100;
    CGPoint offSetPoint = contentScrollView.contentOffset;
    offSetPoint.y = textField.superview.frame.origin.y - offset;
    [self scrollContentViewToPoint:offSetPoint];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == userNameField) {
        
        if (isForgotOptionsSelected == YES) {
            [self scrollContentViewToPoint:CGPointZero];
            
            [textField resignFirstResponder];
        }
        else {
            [passwordField becomeFirstResponder];
        }
    }
    else {
        [passwordField resignFirstResponder];
        [self signInButtonPressed];
    }
    return YES;
}

// Sign in action
- (IBAction)signInButtonPressed {
   // passwordField.text = @"testaccount01";
    [self scrollContentViewToPoint:CGPointZero];
    
    if (![self validateField:userNameField]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (![self validateField:passwordField] && isForgotOptionsSelected == NO) {
        [[[UIAlertView alloc] initWithTitle:@"Password cannot be blank." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [self login];
}

// Hide the keyboard while tapping outside the keyboard frame
- (IBAction)hideKeyBoard:(id)sender  {
    
    [self scrollContentViewToPoint:CGPointZero];
    [self.activeField resignFirstResponder];
}

// Show the sign up screen
- (IBAction)signupNewUser:(id)sender {
    
    [self performSegueWithIdentifier:@"showSignUp" sender:nil];
}

// Login API Succcessful Delegate
- (void)loginUserSuccesful {
    
    [self dismissViewControllerAnimated:YES completion:nil];;
}

#pragma mark
#pragma Password Retreival

// Password Retrieval
- (void)retreivePassword {
    
    [userNameField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    if ([EHHelpers isNetworkAvailable]) {
        NSString *loginXML = [NSString stringWithFormat:EHPasswordRetrieval, userNameField.text,AppID];
        
        NSString *soapBody = [NSString stringWithFormat:SOAP_BODY_XML, loginXML];
        NSString *soapAction = [NSString stringWithFormat:@"%@/PasswordRetrieval", API_ACTION_ROOT];
        
        [self showLoadingView];
        [self.networkOperation retrievePasswordDetailsWithBody:soapBody forAction:soapAction];
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
    }
    
}

#pragma mark Forgot Password Response Delegate

- (void)successfullyRequestedForgotPassword:(NSArray *)data{
    
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    
    if (data > 0) {
        DDXMLElement *password = data[0];
        if ([password.stringValue intValue] == 1) {
            [self updateUnderLineTitle:@"Forgot your password?" withSignInButtonText:@"LOG  IN" withPositionConstraint:81.0];
            isForgotOptionsSelected = NO;
            [EHHelpers showAlertWithTitle:@"" message:@"An email has been sent to you with your password information." delegate:nil];
        }
    }
    
}

- (void)error:(NSError *)operationError {
    
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
    }
    
}

#pragma mark Login

//  Perform Action based on the mode (Forgot Password / Sign In)
- (void)login {
    
    [userNameField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    if (isForgotOptionsSelected == YES) {
        [self retreivePassword];
    }
    else{
        
        if ([EHHelpers isNetworkAvailable]) {
            [self makeUserLogin];
        }
        else {
            [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
        }
    }
}

// Login API
- (void)makeUserLogin {
    
    NSString *loginXML = [NSString stringWithFormat:EHLogin, userNameField.text, [passwordField.text stringByActuallyAddingURLEncoding] ,AppID ];
    
    NSString *soapBody = [NSString stringWithFormat:SOAP_BODY_XML, loginXML];
    NSString *soapAction = [NSString stringWithFormat:@"%@/UserLogin", API_ACTION_ROOT];
    
    [self showLoadingView];
    [self.networkOperation loginUserWithBody:soapBody forAction:soapAction];
    
}

#pragma mark
#pragma mark Login Response Delegate

- (void)successfullyLoggedIn:(NSArray *)loginData {
    
    if ([rememberButton isSelected]) {
        [APP_DELEGATE deleteKeychainValueForIdentifier:@"UserName"];
        [APP_DELEGATE createKeychainValue:userNameField.text forIdentifier:@"UserName"];
    }
    else {
        [APP_DELEGATE deleteKeychainValueForIdentifier:@"UserName"];
    }
    
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    if (loginData!= nil) {
        
        DDXMLElement *login = loginData[0];
        [User loginUserWithInfo:login withUserEmail:userNameField.text withPassword:passwordField.text];
        
        [APP_DELEGATE initiateSessionTimer];
        [EHHelpers registerGAWithCategory:@"User Log In" forAction:@"User Log In"];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else {
        [EHHelpers showAlertWithTitle:@"" message:@"Unable to connect to server" delegate:nil];
    }
    
}

// Scroll Content to particular point
- (void)scrollContentViewToPoint:(CGPoint)location {
    
    [UIView animateWithDuration:0.5 animations:^{
        [contentScrollView setContentOffset:location];
        
    } completion:nil];
    
    
}

// Validate the username is not empty or is in proper format
- (BOOL)validateField:(UITextField *)textField {
    
    if (textField.text.length > 0 && [EHHelpers validateEmail:userNameField.text] == YES) {
        return YES;
    }
    return NO;
}

// ForgotPassword Selected
- (IBAction)forgotPasswordPressed {
    
    isForgotOptionsSelected = !isForgotOptionsSelected;
    [self.activeField resignFirstResponder];
    [self scrollContentViewToPoint:CGPointZero];
    
    if (isForgotOptionsSelected == YES) {
        [self updateUnderLineTitle:@"Log in" withSignInButtonText:@"GET PASSWORD" withPositionConstraint:0.0];
    }
    else{
        [self updateUnderLineTitle:@"Forgot your password?" withSignInButtonText:@"LOG  IN" withPositionConstraint:81.0];
        
    }
    [self.view updateConstraints];
    
    [self animateForgotOptionsWithDuration:0.5];
    
}

// Update the button text that need to be underlined and sign in button caption with position
- (void)updateUnderLineTitle:(NSString*)text withSignInButtonText:(NSString*)signInText withPositionConstraint :(float)positionConstraint {
    
    [loginButton setTitle:signInText forState:UIControlStateNormal];
    [EHHelpers underlineButtonText:forgotYourPasswordButton withString:text];
    self.forgotPasswordOriginContraint.constant = positionConstraint;
    
}
// Animate the position of get password button frame
- (void)animateForgotOptionsWithDuration:(NSTimeInterval)durations{
    
    [self.view updateConstraints];
    [UIView animateWithDuration:durations animations:^{
        rememberView.hidden = isForgotOptionsSelected;
        [self.view layoutIfNeeded];
        
    } completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"showSignUp"]){
        RegistrationViewController *vc = (RegistrationViewController *)[segue destinationViewController];
        vc.delegate =self;
    }
}
// Registration Delegate
- (void)successfullyRegistered:(NSString *)userRegisteredId {
    
    userNameField.text = userRegisteredId;
    passwordField.text = @"";
}
@end
