//
//  MedicineCabinetViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 21/07/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MedicineCabinetCell.h"
#import "MedicineCabinetManualCell.h"
#import "AlarmListViewController.h"
#import "DrugSavingsViewController.h"
#import "SettingsViewController.h"
#import "GettingStartedView.h"
#import "NoDrugView.h"
#import "GAITrackedViewController.h"
#import "AlertHandler.h"
#import "MedicineCabinetDelegate.h"

#define GettingStartedScreenTag 5000

@interface MedicineCabinetViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, MedicineCabinetDelegate ,GettingStartedDelegate,EHOperationProtocol,UITextFieldDelegate> {
    
    IBOutlet UITableView *medicinesTableView;
    IBOutlet UIView *searchView;
    IBOutlet UITextField *drugAddField;
    IBOutlet UIButton *addDrugButton;
    IBOutlet UIButton *deleteDrugButton;
    IBOutlet UIView *deleteOptionsView;
    IBOutlet UIImageView *homePreviewImage;
    NoDrugView *emptyCabinetView;
    UIButton *hideKeyBoardButton;

    
}


@property (nonatomic ,strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSMutableArray *medicinesListArray;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *addDrugHeightConstraint,*deleteManualDrugOptionViewConstraint;

@property (nonatomic ,strong) id selectedMedicine;
@property (nonatomic ,strong) EHOperation *networkOperation;

- (IBAction)showMenu;
- (IBAction)showHideSearch;
- (IBAction)addDrug;
- (IBAction)scrollMedListToTop:(id)sender;

- (IBAction)undoManualDrugDeletion:(id)sender;
- (IBAction)deleteManualDrug:(id)sender;
- (IBAction)showProfileSettings:(id)sender;

@end
