//
//  DetailedSavingsViewController.h
//  EngageHealth
//
//  Created by Nassif on 09/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailedSavingCell.h"
#import "EHHelpers.h"
#import "PharmacyDetailViewController.h"
#import "InfoAlert.h"
#import "User.h"
#import "Claims.h"
#import "Drugs.h"
#import "LoadingView.h"
#import "OrchardPharmacyViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "AlternateDrug.h"
#import "GAITrackedViewController.h"


@interface DetailedSavingsViewController : GAITrackedViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    IBOutlet UIView *sortOptionsView;
    IBOutlet UITableView *savingsTableView;
    IBOutlet UITextField *searchTextField;
    IBOutlet UILabel *titleLabel;
    UIButton *hideKeyBoardButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIView *keyBoardSearchView;
    IBOutlet UIView *noPharmacyView;
}

@property int sortType;
@property (nonatomic ,strong) NSMutableArray *pharmacy;
@property (nonatomic ,strong) NSDictionary *selectedPharmacy;

@property (nonatomic ,strong) AlternateDrug *drugInfo;
@property (nonatomic ,strong) Claims *claimsInfo;

@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *keyBoardSearchButtonContraint,*noPharmacyOriginConstraint, *sortOptionsYConstraint;
@property BOOL isSearching;
@property (nonatomic ,strong) LoadingView *customLoadingView;


- (IBAction)backAction:(id)sender;
- (IBAction)showSortOptionsView:(id)sender;
- (IBAction)sortSavingsByType:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)searchSavingByLocation:(id)sender;
- (IBAction)cancelZipCodeSearch:(id)sender;

@end
