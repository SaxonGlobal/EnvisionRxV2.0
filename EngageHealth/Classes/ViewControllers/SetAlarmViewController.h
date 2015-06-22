//
//  SetAlarmViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 8/6/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectDaysViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "EHHelpers.h"
#import "AlertHandler.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


@interface SetAlarmViewController : GAITrackedViewController <SelectDaysDelegate ,UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate> {
    
    IBOutlet UILabel *courseDurationLabel;
    IBOutlet UILabel *endDateLabel;
    IBOutlet UILabel *alarmSoundLabel;
    IBOutlet UITextField *drugHeaderField;
    
    IBOutlet UILabel *titleLabel;
    
    
    IBOutlet UIDatePicker *alertTimePicker;
    IBOutlet UIDatePicker *alertEndDatePicker;
    
    IBOutlet UIScrollView *alarmScrollView;
    
    IBOutlet UITableView *soundListTableView;
    IBOutlet UIView *soundListView;
    
    IBOutlet UIView *endDateView;
    NSString *alarmId;
}

@property (nonatomic, strong) id drugDict;
@property (nonatomic, retain) NSMutableDictionary *userAlertSettings, *alertDaysDict;
@property (nonatomic, retain) NSMutableArray *alarmArray, *alertTimeArray;

@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *endDateOriginConstraint;
@property (nonatomic ,strong) NSMutableArray *systemSoundsArray;
@property (nonatomic ,strong) NSDateFormatter *dateFormatter;

@property int systemSoundSelectedIndex;

- (IBAction)goBack;

- (IBAction)selectRepeatIntervalForDrug:(id)sender;
- (IBAction)selectedAlarmSoundForDrug:(id)sender;



- (IBAction)showEndDatePicker:(id)sender;
- (IBAction)hideEndDatePicker:(id)sender;
- (IBAction)addEndDate:(id)sender;

- (IBAction)hideSoundList:(id)sender;
- (IBAction)addSoundForAlert:(id)sender;


@end
