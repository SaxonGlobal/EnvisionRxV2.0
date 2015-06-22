//
//  DrugSavingsViewController.h
//  EngageHealth
//
//  Created by Nassif on 26/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrugSavingCell.h"
#import "Constants.h"
#import "InfoAlert.h"
#import "DetailedSavingsViewController.h"
#import "LoadingView.h"
#import "EHOperation.h"
#import "Claims+DAO.h"
#import "GAITrackedViewController.h"




@interface DrugSavingsViewController : GAITrackedViewController <UITableViewDataSource,UITableViewDelegate,EHOperationProtocol> {
    
    IBOutlet UILabel *drugTitle;
    IBOutlet UITableView *drugSavingsTableView;
    LoadingView *customLoadingView;

}

@property (nonatomic ,strong) NSMutableArray *requestedCall;
@property (nonatomic ,strong) EHOperation *networkOperation;
- (IBAction)back:(id)sender;

@property (nonatomic ,strong) id drugInfo;
@property (nonatomic ,strong) NSMutableArray *drugs;
@property (nonatomic ,strong) AlternateDrug *selectedDrug;
@end
