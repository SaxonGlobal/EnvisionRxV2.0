//
//  AlarmListViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 8/6/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmCell.h"
#import "SetAlarmViewController.h"
#import "AlertHandler.h"
#import "GAITrackedViewController.h"


@interface AlarmListViewController : GAITrackedViewController <UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UIView *normalHeaderView,*editingHeaderView;
    IBOutlet UILabel *medTitleLabel,*medTitleLabel2;
    IBOutlet UITableView *alarmListTableView;
    IBOutlet UIView *noAlertsView;
}

@property BOOL isEditing;
@property (nonatomic ,strong) id drugInfo;
@property (nonatomic ,strong) NSMutableArray *alarmLists;
@property (nonatomic ,strong) NSDictionary *selectedUserAlert;

- (IBAction)editAlarm:(id)sender;
- (IBAction)didCompleteEditing:(id)sender;

- (IBAction)goBack;

- (IBAction)addNewAlert:(id)sender;

@end
