//
//  FindCareViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 7/24/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PharmacyCellTableViewCell.h"
#import "PharmacyDetailViewController.h"
#import "InfoAlert.h"
#import "CustomTextField.h"
#import "LoadingView.h"
#import "UIViewController+AMSlideMenu.h"
#import "EHHelpers.h"
#import "GAITrackedViewController.h"


enum {
    SearchByZipCode,
    SearchByGPS
    
};

@interface FindCareViewController : GAITrackedViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,EHOperationProtocol> {
    
    IBOutlet UITableView *pharmacyLisTableView;
    IBOutlet UITextField *zipCodeSearchField;
    UIButton *hideKeyBoardButton;
    IBOutlet UIView *keyBoardSearchView;
    LoadingView *customLoadingView;
    IBOutlet UIView *noPharmacyView;

}


@property int searchMode;

@property (nonatomic ,strong) NSMutableArray *pharmacyListArray;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *keyBoardSearchButtonContraint;
@property (nonatomic ,strong) LoadingView *customLoadingView;
@property BOOL isSearching;

- (IBAction)showMenu;

- (IBAction)searchByGPS:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)cancelSearchByZipCode:(id)sender;

@end
