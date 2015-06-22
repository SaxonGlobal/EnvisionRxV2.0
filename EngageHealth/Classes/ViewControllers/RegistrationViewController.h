//
//  RegistrationViewController.h
//  EngageHealth
//
//  Created by Nassif on 13/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHHelpers.h"
#import "InfoAlert.h"
#import "CustomHTMLPageView.h"
#import "User+DAO.h"
#import "NSString+Mobomo.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


enum {
    None = 100,
    Male = 101,
    Female = 102
}GenderCode;

enum {
    Relation = 1000,
    SecretQuestion = 1001
}DropDown;

#define EHRegTextColor [UIColor colorWithRed:81.0/225.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]

@protocol RegistrationDelegate <NSObject>

- (void)successfullyRegistered:(NSString*)userRegisteredId;

@end

@interface RegistrationViewController : GAITrackedViewController <UITextFieldDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet UIView *contentView;
    
    IBOutlet UITextField *firstName,*lastName,*dob,*memberId,*emailId,*password,*confirmPassword,*relationShipId,*secretAnswer,*secretQn;
    IBOutlet UIButton *femaleButton;
    IBOutlet UIButton *maleButton;
    
    IBOutlet UIView *regPage1,*regPage2;
    IBOutlet  UITableView *dropDownTableView;
    
    IBOutlet UIView *dOBDatePickerView;
    IBOutlet UIDatePicker *datePicker;
    BOOL isDropDownShown;
    IBOutlet CustomHTMLPageView *customHtmlPageView;
    IBOutlet UIButton *continueButton;
    
}

@property int genderCode,relationId,secretQuestionId,selectedDropDown;
@property (weak, nonatomic) UITextField *activeField;
@property (nonatomic , strong) NSArray *relationList;
@property (nonatomic ,strong) id<RegistrationDelegate>delegate;
@property (nonatomic ,strong) NSDateFormatter *dateFormatter;

@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *textCOntainerHeightCOntraint;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *firstNameHeightContraint,*lastNameHeightContraint,*dobHeightConstraint,*memberHeightConstraint,*relationHeightConstraint,*emailHeightConstraint,*passheightConstraint,*confirmPassHeightConstraint,*secretQuestionHeightConstraint,*answerHeightConstraint,*firstScreenPagingBottomContraint ,*secretQuestionSpacingConstraint, *termsOriginConstraint,*termsHeightConstraint,*continueOptions;

- (IBAction)showNextPage;
- (IBAction)showPreviousPage;

- (IBAction)selectGender:(id)sender;
- (IBAction)showRelationwShip:(id)sender;

- (IBAction)selectYourSecretQuestion:(id)sender;


- (IBAction)registerUser:(id)sender;
- (IBAction)cancelRegistration;
- (IBAction)showDropDown:(id)sender;

- (IBAction)showDOBDatePicker:(id)sender;
- (IBAction)hideDOBPicker:(id)sender;
- (IBAction)addDOBDate:(id)sender;
- (IBAction)hideKeyBoardWhileTap;

- (IBAction)showTerms:(id)sender;
- (IBAction)cancelTermsView:(id)sender;

@end
