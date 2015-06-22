//
//  RegistrationViewController.m
//  EngageHealth
//
//  Created by Nassif on 13/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "RegistrationViewController.h"

@interface RegistrationViewController ()<EHOperationProtocol>
@property (nonatomic ,strong) EHOperation *networkOperation;
@end

@implementation RegistrationViewController
@synthesize activeField;
@synthesize genderCode;
@synthesize relationList;

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
    self.screenName = @"Registration";
    [self setNeedsStatusBarAppearanceUpdate];
    
    secretAnswer.textColor = EHRegTextColor;
    secretQn.textColor = EHRegTextColor;
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [maleButton setSelected:NO];
    [femaleButton setSelected:NO];
    
    isDropDownShown = NO;
    customHtmlPageView.contentType = TermsAndCondition;
    self.textCOntainerHeightCOntraint.constant = 100;
    self.termsOriginConstraint.constant = self.view.frame.size.height;
    self.termsHeightConstraint.constant = self.view.frame.size.height - 20;
    self.firstScreenPagingBottomContraint.constant = 92;
    self.continueOptions.constant = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContinueOtpions) name:@"ShowContinue" object:nil];
    
    dOBDatePickerView.hidden = YES;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    // [datePicker setMaximumDate:[NSDate date]];
    [self updateHeightConstraints];
    self.selectedDropDown = 0;
    self.genderCode = None ;
    self.relationId = 1;
    self.secretQuestionId = 1;
    [self updateTextFieldPlaceHolder];
    [self showFormPage:regPage1];
    
    [self registerDropDownView];
    [self addNotificationListeneForKeyBoard];
    [self loadRelationList];
    
}

- (void)showContinueOtpions {
    
    self.continueOptions.constant = 55;
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark
#pragma mark Register/Initialise the drop view for relationship/secret question view

- (void)registerDropDownView {
    
    dropDownTableView = [[UITableView alloc] init];
    dropDownTableView.delegate= self;
    dropDownTableView.dataSource = self;
    
    NSString* cellIdentifier = @"dropDownTableIdentifier";
    
    [dropDownTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    dropDownTableView.layer.borderColor = EHRegTextColor.CGColor;
    
}

#pragma mark
#pragma mark KeyBoard Notification Registration

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

#pragma mark
#pragma mark RelationShip Setting
// Create relation drop down list
- (void)loadRelationList {
    self.relationList =  @[@{ @"text":@"Member",@"id":@"1"},
                           @{@"text":@"Spouse",@"id":@"2"},
                           @{@"text":@"I am a domestic partner",@"id":@"3"},
                           @{@"text":@"I am an adult dependent",@"id":@"4"}
                           ];
}

#pragma mark
#pragma mark CustomisePlaceHolder
// Customise the textfield with color, text and show required fields
- (void)updateTextFieldPlaceHolder {
    
    [self updatePlaceHolder:@"First Name " withTextField:firstName isRequired:NO];
    [self updatePlaceHolder:@"Last Name " withTextField:lastName isRequired:NO];
    [self updatePlaceHolder:@"Date of Birth " withTextField:dob isRequired:NO];
    [self updatePlaceHolder:@"Member ID " withTextField:memberId isRequired:NO];
    [self updatePlaceHolder:@"Relationship " withTextField:relationShipId isRequired:NO];
    [self updatePlaceHolder:@"Member ID " withTextField:memberId isRequired:NO];
    [self updatePlaceHolder:@"Email (Username) " withTextField:emailId isRequired:NO];
    [self updatePlaceHolder:@"Create Password " withTextField:password isRequired:NO];
    [self updatePlaceHolder:@"Confirm Password " withTextField:confirmPassword isRequired:NO];
    [self updatePlaceHolder:@"Secret Question " withTextField:secretQn isRequired:NO];
    [self updatePlaceHolder:@"Answer " withTextField:secretAnswer isRequired:NO];
    
}

#pragma mark
#pragma mark FormPage

// Show the screen1 or screen2 based on the screen selected
- (void)showFormPage:(UIView*)registerFormView {
    
    for (UIView *childView in contentView.subviews) {
        [childView removeFromSuperview];
    }
    
    [contentView addSubview:registerFormView];
    
    UIView *formView = registerFormView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(formView);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[formView]|" options:0  metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[formView]|" options:0  metrics:nil views:views]];
    [contentView updateConstraints];
    
}

#pragma mark
#pragma mark Gender Selection
- (IBAction)selectGender:(id)sender {
    
    [maleButton setSelected:NO];
    [femaleButton setSelected:NO];
    UIButton *btn = (UIButton*)sender;
    self.genderCode = (int)btn.tag;
    [sender setSelected:YES];
    
}

#pragma mark
#pragma mark RelationShipSelection

- (IBAction)showRelationwShip:(id)sender {
    
    self.selectedDropDown = Relation;
    [self showDropDown:sender];
    
}

#pragma mark
#pragma mark SecretQuestionSelection
// Show secret question fields
- (IBAction)selectYourSecretQuestion:(id)sender {
    self.selectedDropDown = SecretQuestion;
    
    [self showDropDown:sender];
}

#pragma mark
#pragma mark Validation
// Validate User Registration
- (IBAction)registerUser:(id)sender {
    [self.activeField resignFirstResponder];
    if ([firstName.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your First Name." delegate:nil];
    }
    else if ([lastName.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your Last Name." delegate:nil];
        
    }
    else if ([dob.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your Date of Birth." delegate:nil];
        
    }
    
    else if (self.genderCode == None) {
        [EHHelpers showAlertWithTitle:@"" message:@"Select your Gender." delegate:nil];
        
    }
    else if ([memberId.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your Member ID." delegate:nil];
        
    }
    
    else if ([relationShipId.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your Relationship." delegate:nil];
        
    }
    
    else if ([emailId.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter your Email." delegate:nil];
        
    }
    else if ([EHHelpers checkForEmailValidation:emailId.text] == NO){
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter a valid Email." delegate:nil];
    }
    else if ([password.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"You must enter your Password." delegate:nil];
        
    }
    else if ([EHHelpers validatePassword:password.text] == NO){
        [EHHelpers showAlertWithTitle:@"" message:@"Password must contain at least 6 characters and 3 of the following 4 options: upper case, lower case, special character, and number." delegate:nil];
    }
    
    else if ([confirmPassword.text length] == 0) {
        if ([password.text length] == 0) {
            [EHHelpers showAlertWithTitle:@"" message:@"You must enter your Password." delegate:nil];
        }
        else{
            [EHHelpers showAlertWithTitle:@"" message:@"Confirm your Password." delegate:nil];
            
        }
    }
    else if ([confirmPassword.text length] > 0 && [password.text length] > 0 && (![confirmPassword.text isEqualToString:password.text]) ){
        
        [EHHelpers showAlertWithTitle:@"" message:@"Passwords do not match, please re-enter your Password." delegate:nil];
    }
    else if ([secretQn.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Enter your Secret Question." delegate:nil];
        
    }
    
    else if ([secretAnswer.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Enter your Secret Answer." delegate:nil];
        
    }
    else{
        if ([EHHelpers isNetworkAvailable]) {
            [self makeUserRegistration];
        }
        else{
            [EHHelpers showAlertWithTitle:@"" message:@"No Network Available" delegate:nil];
        }
    }
}


// Register userr with the client DB
#pragma mark
#pragma mark Register API

- (void)makeUserRegistration {
    
    NSString *gender = (self.genderCode == Male ) ? @"M" : @"F";
    const char *character = [gender UTF8String];
    int genderValue = (int)*character;
    
    
    NSString *soapAction = [NSString stringWithFormat:@"%@/UserRegistration", API_ACTION_ROOT];
    NSString *soapBodyXML = [NSString stringWithFormat:EHUserRegistration,firstName.text,lastName.text,dob.text,[NSString stringWithFormat:@"%d",genderValue],memberId.text,self.relationId,emailId.text,[password.text stringByActuallyAddingURLEncoding],self.secretQuestionId,secretAnswer.text,0, AppID] ;
    
    NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
    
    [InfoAlert info:@"Processing your request"];
    [self.networkOperation registerUserWithBody:soapBody forAction:soapAction];
    
}

#pragma mark
#pragma mark Register API Delegate

- (void)successFullyRegistered:(NSArray *)newUserData {
    
    [InfoAlert dismiss];
    if (newUserData!= nil) {
        DDXMLElement *login = newUserData[0];
        [User createUserWithLoginInfo:login withUserEmail:emailId.text withPassword:password.text];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
        // sent with all subsequent hits.
//        [tracker set:@"&uid"
//               value:[[APP_DELEGATE currentUser] guid]];
        
        // This hit will be sent with the User ID value and be visible in User-ID-enabled views (profiles).
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"            // Event category (required)
                                                              action:@"User Registration"  // Event action (required)
                                                               label:nil              // Event label
                                                               value:nil] build]];

        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else {
        [EHHelpers showAlertWithTitle:@"" message:@"Unable to connect to server." delegate:nil];
    }
    
}

- (void)error:(NSError *)operationError {
    
    [InfoAlert dismiss];
    
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
        if ([errorMessage isEqualToString:@"Invalid Member ID, Name or DOB"]) {
            [self showPreviousPage] ;
        }
    }
    
}

#pragma mark

// Cancel Registration process
- (IBAction)cancelRegistration {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
// Setting the height of the text box based on the device height
- (void)updateHeightConstraints {
    
    NSArray *layoutHeightConstraint = @[self.firstNameHeightContraint,self.lastNameHeightContraint,self.dobHeightConstraint,self.memberHeightConstraint,self.relationHeightConstraint,self.emailHeightConstraint,self.passheightConstraint,self.confirmPassHeightConstraint,self.secretQuestionHeightConstraint,self.answerHeightConstraint];
    
    for (NSLayoutConstraint *heightConstraints in layoutHeightConstraint) {
        heightConstraints.constant = IS_IPHONE_5 ? 51 : 33;
    }
    
    self.secretQuestionSpacingConstraint.constant = 4;
}

#pragma mark
#pragma mark CustomiseTextFieldPlaceholder

- (void)updatePlaceHolder:(NSString*)placeHolderText withTextField:(UITextField*)regTextField isRequired:(BOOL)isRequired{
    
    NSMutableAttributedString *subString = [[NSMutableAttributedString alloc] initWithString:placeHolderText];
    [subString addAttribute:NSForegroundColorAttributeName value:EHRegTextColor range:NSMakeRange(0, subString.length)];
    
    // if (isRequired) {
    [subString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0] range:NSMakeRange(0, placeHolderText.length)];
    
    // }
    
    if ([regTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        regTextField.attributedPlaceholder = subString;
    } else {
        NSLOG(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    regTextField.textColor = EHRegTextColor;
    
}


#pragma mark
#pragma mark Date of Birth Setting
// Show the end date selection view
- (IBAction)showDOBDatePicker:(id)sender {
    
    dOBDatePickerView.hidden = NO;
    [self.activeField resignFirstResponder];
    
}

// Hide End Date Selection View
- (IBAction)hideDOBPicker:(id)sender {
    
    [self hideDOBDateSelectionView];
}

- (void)hideDOBDateSelectionView {
    
    dOBDatePickerView.hidden = YES;
    
}
// Add end date for drug
- (IBAction)addDOBDate:(id)sender {
    
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    dob.text = [self.dateFormatter stringFromDate:datePicker.date];
    [self hideDOBDateSelectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Textfield Delegate
// Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)sender
{
    
    isDropDownShown = NO;
    [self clearDropDownScreen];
    self.activeField = sender;
}

- (void)textFieldDidEndEditing:(UITextField *)sender
{
    [self.activeField resignFirstResponder];
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

#pragma mark
#pragma mark Keyboard notifications actions

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    if ((self.activeField == memberId ) || (self.activeField == secretAnswer)) {
        [UIView animateWithDuration:0.5 animations:^{
            
            float heightOrigin = (self.activeField == secretAnswer) ? contentScrollView.contentSize.height - self.activeField.superview.frame.origin.y :  self.activeField.superview.frame.origin.y - kbRect.size.height + (IS_IPHONE_5 ? 0 : 50);
            contentScrollView.contentOffset =     CGPointMake(0,  heightOrigin  );
            
        } completion:nil];
        
        
    }
}

// Keyboard notifications actions : On hidden

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    isDropDownShown = NO;
    [self clearDropDownScreen];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        contentScrollView.contentInset = contentInsets;
        contentScrollView.scrollIndicatorInsets = contentInsets;
        
    } completion:nil];
    
}

// Hide the key board while tappping outside the keyboard frame
- (IBAction)hideKeyBoardWhileTap {
    
    [self.activeField resignFirstResponder];
    isDropDownShown = NO;
    [self clearDropDownScreen];
}

#pragma mark
#pragma mark Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return (self.selectedDropDown == Relation) ? [self.relationList count] : [[APP_DELEGATE securityQuestions]count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:    (NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropDownTableIdentifier"  forIndexPath:indexPath];
    
    NSDictionary *dict = (self.selectedDropDown == Relation) ? self.relationList[indexPath.row] : [APP_DELEGATE securityQuestions][indexPath.row];
    cell.textLabel.text = dict[@"text"];
    cell.textLabel.font = [UIFont fontWithName:APPLICATION_FONT_NORMAL size:14.0];
    cell.textLabel.textColor = EHRegTextColor;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int numberId = 1;
    if (self.selectedDropDown == Relation) {
        numberId =  [self.relationList[indexPath.row][@"id"]intValue];
        relationShipId.text = self.relationList[indexPath.row][@"text"];
        self.relationId = numberId;
    }
    else if (self.selectedDropDown == SecretQuestion) {
        numberId =  [[APP_DELEGATE securityQuestions][indexPath.row][@"id"]intValue];
        secretQn.text = [APP_DELEGATE securityQuestions][indexPath.row][@"text"];
    }
    self.firstScreenPagingBottomContraint.constant = 92;
    self.secretQuestionSpacingConstraint.constant = 4;
    isDropDownShown = NO;
    [dropDownTableView removeFromSuperview];
    
    [contentScrollView updateConstraints];
    
    [UIView animateWithDuration:0.5 animations:^{
        [contentView layoutIfNeeded];
        [contentScrollView layoutIfNeeded];
        
        
        
    } completion:^(BOOL finished) {
        nil;
    }];
}


#pragma mark
#pragma mark DropDown

- (void)clearDropDownScreen {
    
    [dropDownTableView removeFromSuperview];
    self.firstScreenPagingBottomContraint.constant = 92;
    self.secretQuestionSpacingConstraint.constant = 4;
    [contentScrollView updateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [contentScrollView layoutIfNeeded];
        contentScrollView.contentOffset = CGPointZero;
    } completion:nil];
    
    
}

- (IBAction)showDropDown:(id)sender{
    
    [self.activeField resignFirstResponder];
    
    isDropDownShown = !isDropDownShown;
    
    if (isDropDownShown == NO) {
        [self clearDropDownScreen];
        return;
        
    }
    
    UIButton *btn = (UIButton*)sender;
    dropDownTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *containerView = (self.selectedDropDown == Relation ) ? regPage1 : regPage2;
    [containerView addSubview:dropDownTableView];
    
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:13]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-12.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:btn attribute: NSLayoutAttributeBottom multiplier:1.0 constant:(self.selectedDropDown == Relation ) ? 0 : 0]];
    [dropDownTableView reloadData];
    
    [containerView updateConstraints];
    [containerView layoutIfNeeded];
    
    if (self.selectedDropDown == Relation) {
        self.firstScreenPagingBottomContraint.constant = 210;
    }
    else {
        
        self.secretQuestionSpacingConstraint.constant = 210;
    }
    
    
    [UIView animateWithDuration:0.5 animations:^{
        contentScrollView.contentOffset  =     CGPointMake(0, contentScrollView.contentSize.height - 250);
        [contentScrollView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        ;
    }];
    
}

-(NSString *) checkForEmptyField:(NSString *) inputString{
    
    NSCharacterSet *whitespace=[NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [inputString stringByTrimmingCharactersInSet:whitespace];
    return trimmedString;
}

//Show next registration form fields
#pragma mark
#pragma mark Screen1/Screen2
- (IBAction)showNextPage {
    
    isDropDownShown = NO;
    
    self.firstScreenPagingBottomContraint.constant = 92;
    self.secretQuestionSpacingConstraint.constant = 4;
    [dropDownTableView removeFromSuperview];
    
    if ([[self checkForEmptyField:firstName.text] length]== 0) {
        
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter your First Name." delegate:nil];
        
    }
    else if ([[self checkForEmptyField:lastName.text] length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter your Last Name." delegate:nil];
        
    }
    else if ([[dob text] length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter your Date of Birth." delegate:nil];
        
    }
    else if (self.genderCode == None) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please select your Gender." delegate:nil];
        
    }
    else if ([[self checkForEmptyField:memberId.text] length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter your Member ID." delegate:nil];
        
    }
    
    else if ([relationShipId.text length] == 0) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enter your Relationship." delegate:nil];
        
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            [contentScrollView scrollsToTop];
            [self showFormPage:regPage2];
            
            
        } completion:nil];
        
    }
    
}

//Show previous registration form fields
- (IBAction)showPreviousPage {
    
    isDropDownShown = NO;
    self.firstScreenPagingBottomContraint.constant = 92;
    self.secretQuestionSpacingConstraint.constant = 4;
    
    [UIView animateWithDuration:0.5 animations:^{
        [contentScrollView scrollsToTop];
        [self showFormPage:regPage1];
        
    } completion:nil];    [dropDownTableView removeFromSuperview];
    // contentScrollView.contentOffset = CGPointMake(0, 320);
}


#pragma mark
#pragma mark TermsAndCondition

- (IBAction)showTerms:(id)sender{
    
    [self.activeField resignFirstResponder];
    self.termsOriginConstraint.constant = 0;
    [self.view updateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        
        
    } completion:nil];
    [customHtmlPageView loadHTMLData];
}

- (IBAction)cancelTermsView:(id)sender {
    
    self.termsOriginConstraint.constant = self.view.frame.size.height;
    [self.view updateConstraints];
    [customHtmlPageView cancel];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
@end
