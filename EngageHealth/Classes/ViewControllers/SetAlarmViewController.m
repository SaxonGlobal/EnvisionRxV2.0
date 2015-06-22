//
//  SetAlarmViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 8/6/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "SetAlarmViewController.h"
#import "Claims.h"
#import "Drugs.h"

@interface SetAlarmViewController ()

@end

@implementation SetAlarmViewController
@synthesize endDateOriginConstraint;

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
    self.screenName = @"Alarm Settings";
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
#endif
    
    [self.view setUserInteractionEnabled:YES];
    [EHHelpers copyFileIfNeeded:@"Sounds.plist"];
    soundListView.hidden = YES;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    [self prepareSoundList];
    [self prepareEndDateSelectionView];
    
    drugHeaderField.text = [self drugName];

    self.systemSoundSelectedIndex = 0;
    [self loadExistingAlertSettings];
    [soundListTableView reloadData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
// Hide the key board while tappping outside the keyboard frame
- (IBAction)hideKeyBoardWhileTap {
    
    [drugHeaderField resignFirstResponder];
    alarmScrollView.contentOffset = CGPointMake(0, 0);
    
}

// Add button to scroll container to dismiss the keyboard while tapping outside the keyboard
- (void)addKeyboardButtonToContainerScroll {
    
    [UIView animateWithDuration:0.5 animations:^{
        [alarmScrollView setContentOffset:CGPointMake(0, 150)];

    } completion:^(BOOL finished) {
        ;
    }];
    
}

#pragma mark
#pragma mark ExistingAlertSetting
// Load existing user alert settings
- (void)loadExistingAlertSettings {
    
    if ([[self.userAlertSettings allKeys] count] > 0) {
        
        courseDurationLabel.text = [EHHelpers repeatStatusForDrug:self.userAlertSettings[@"repeat"]];
        endDateLabel.text = [self.userAlertSettings[@"endDate"] length] > 0 ? self.userAlertSettings[@"endDate"] : @"None";
        drugHeaderField.text = [self.userAlertSettings[@"customheader"] length] > 0 ? self.userAlertSettings[@"customheader"] : [self drugName];;
        self.systemSoundSelectedIndex = [self indexOfSoundSelected];
        self.alertDaysDict = [NSMutableDictionary dictionaryWithDictionary:self.userAlertSettings[@"repeat"]];
        alarmSoundLabel.text =  self.systemSoundSelectedIndex > 0 ? self.systemSoundsArray[self.systemSoundSelectedIndex] : @"None";
        alarmId = self.userAlertSettings[@"alarmId"];
        
    }
}


// Select the repeat interval for the drug
- (IBAction)selectRepeatIntervalForDrug:(id)sender {
    
    [self performSegueWithIdentifier:@"showDaysSelection" sender: nil];
}

#pragma mark
#pragma mark EndDate Selection

// Prepare end date view with hidden status and minimum date as current date
- (void)prepareEndDateSelectionView {
    
    endDateView.hidden = YES;
    [alertEndDatePicker setMinimumDate:[NSDate date]];
    
}
// Show the end date selection view
- (IBAction)showEndDatePicker:(id)sender {
    
    endDateView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        
        [alarmScrollView setContentOffset:CGPointMake(0, [EHHelpers isIphone5Device] ? 100 : 170)];
    }];
    
}

// Hide End Date Selection View
- (IBAction)hideEndDatePicker:(id)sender {
    
    endDateLabel.text = @"None";
    [self hideEndDateSelectionView];
}

- (void)hideEndDateSelectionView {
    
    endDateView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        [alarmScrollView setContentOffset:CGPointMake(0, 0)];
    }];

}
// Add end date for drug
- (IBAction)addEndDate:(id)sender {
    
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    endDateLabel.text = [self.dateFormatter stringFromDate:alertEndDatePicker.date];
    [self hideEndDateSelectionView];
}


//Delegate method called after selecting the days - just before coming to this view
#pragma mark
#pragma mark Repeat Delegate
- (void)selectedDayUserData:(NSMutableDictionary *)userData {
    
    courseDurationLabel.text = [EHHelpers repeatStatusForDrug:userData];
    self.alertDaysDict = [NSMutableDictionary dictionaryWithDictionary:userData];
}

#pragma mark 
#pragma mark DeleteNotification

- (void)deleteNotification {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"alarmId"]];
        if ([uid isEqualToString:self.userAlertSettings[@"alarmId"]])
        {
            [app cancelLocalNotification:oneEvent];
        }
    }
}

#pragma mark
#pragma mark Save Alert Action
- (IBAction)addAlertTime {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
    // sent with all subsequent hits.
    //        [tracker set:@"&uid"
    //               value:[[APP_DELEGATE currentUser] guid]];
    
    // This hit will be sent with the User ID value and be visible in User-ID-enabled views (profiles).
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"            // Event category (required)
                                                          action:@"New Alert"  // Event action (required)
                                                           label:nil              // Event label
                                                           value:nil] build]];

    [self performSelectorInBackground:@selector(deleteNotification) withObject:nil];

    NSArray *repeatDayOrdinals = [self getRepeatDayOrdinals];
    
    NSTimeInterval time = floor([alertTimePicker.date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    [alertTimePicker setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:time]];

    //If no repeat or repeat all days, schedule using iOS available repeat counts
    [self saveAlertForDrug:alertTimePicker.date];
    
    if ([repeatDayOrdinals count] == 0 || [repeatDayOrdinals count] == 7) {
        
        //check if selected time expired today, if so, schedule for tomorrow
        if ([[NSDate date] compare:alertTimePicker.date] != NSOrderedAscending) {
            //add 1 day = 24hrs * 60 mins * 60 seconds
            NSDate *date = [alertTimePicker.date dateByAddingTimeInterval:DAY_IN_SECONDS];
            [alertTimePicker setDate:date];
        }
        [AlertHandler scheduleNotificationForDate:alertTimePicker.date withDrugInfo:[self alertDetailsForDrug:alertTimePicker.date]];
    }
    else { //schedule seperate notification for each day
        
        NSDate *initialDate = alertTimePicker.date;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit fromDate:initialDate];
        NSUInteger weekdayToday = [components weekday];
        
        for (id obj in repeatDayOrdinals) {
            
            NSInteger daysToTarget =  weekdayToday - [obj intValue];
            if (daysToTarget < 0) {
                daysToTarget += 7;
            }
            
            NSDate *followingTargetDay = [initialDate dateByAddingTimeInterval:DAY_IN_SECONDS*daysToTarget];
            [AlertHandler scheduleNotificationForDate:followingTargetDay withDrugInfo:[self alertDetailsForDrug:alertTimePicker.date]];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//code to add the alert as local notification

- (NSString*)drugName {
    BOOL manualDrug = ![self.drugDict isKindOfClass:[Claims class]];
    if (manualDrug) {
        return self.drugDict[@"drugName"];
    }
    Claims *claimObj = (Claims *)self.drugDict;
    return claimObj.drug.proddescabbrev;
    
}

// Data for saving alert
- (NSDictionary*)alertDetailsForDrug:(NSDate*)notificationDate {
  
    NSArray *repeatDayOrdinals = [self getRepeatDayOrdinals];
   
    if ([repeatDayOrdinals count] == 0 || [repeatDayOrdinals count] == 7) {

        //check if selected time expired today, if so, schedule for tomorrow
        if ([[NSDate date] compare:notificationDate] != NSOrderedAscending) {
            //add 1 day = 24hrs * 60 mins * 60 seconds
            notificationDate = [notificationDate dateByAddingTimeInterval:DAY_IN_SECONDS];
        }
    }

    
    [self.dateFormatter setDateFormat:@"hh:mm a"];

    NSMutableDictionary *drug = [NSMutableDictionary dictionary];
    drug[@"name"] = [self drugName];
    drug[@"alertTime"] = [self.dateFormatter stringFromDate:alertTimePicker.date];
    drug[@"repeat"] = [NSDictionary dictionaryWithDictionary:self.alertDaysDict];
    drug[@"customheader"] = drugHeaderField.text;
    drug[@"sound"] = (self.systemSoundSelectedIndex != 0) ?  self.systemSoundsArray[self.systemSoundSelectedIndex]
    : @"";
    drug[@"isActive"] = @(1);
    drug[@"startDate"] = notificationDate;
    alarmId = [alarmId length] > 0 ? alarmId : [EHHelpers uuid];
    drug[@"alarmId"] =  alarmId;
    
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    drug[@"endDate"] = [endDateLabel.text isEqualToString:@"None"] ? @"" : [self.dateFormatter stringFromDate:alertEndDatePicker.date];
    User *currentUser = [APP_DELEGATE currentUser];
    if (currentUser != nil) {
        drug[@"userId"] = currentUser.memberId;
    }
    return drug;
    
}

// Save the current alarm date
- (void)saveAlertForDrug:(NSDate*)notificationDate{
    
    NSDictionary *drugDetails = [self alertDetailsForDrug:notificationDate];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *alarm = [NSMutableArray array];
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        NSString *userMedString = [NSString stringWithFormat:@"%@_%@_%@",kUserAlerts,currentuser.email,[self drugName]];;
        
        NSArray *userAlarms = (NSArray*)[userDefaults objectForKey:userMedString];
        
        if (userAlarms.count > 0 ) {
            [alarm addObjectsFromArray:userAlarms];
        }
        if ([alarm containsObject:self.userAlertSettings]) {
            [alarm removeObject:self.userAlertSettings];
        }
        [alarm addObject:drugDetails];
        if ([alarm count] > 0) {
            [userDefaults setObject:[NSArray arrayWithArray:alarm] forKey:userMedString];
        }
        
    }
    
    
}


//Get weekday ordinals for the days to repeat alarm - Sunday = 1, Saturday = 7
- (NSArray *)getRepeatDayOrdinals {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (id obj in [self.alertDaysDict allKeys]) {
        if ([[self.alertDaysDict objectForKey:obj] intValue] == 1) {
            [tempArray addObject:obj];
        }
    }
    
    return tempArray;
}

#pragma mark
#pragma UITableVIewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.systemSoundsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        tableCell.accessoryType = UITableViewCellAccessoryNone ;
        
    }
    tableCell.textLabel.text = self.systemSoundsArray[indexPath.row];
    tableCell.textLabel.font = [UIFont fontWithName:APPLICATION_FONT_NORMAL size:17.0];
    
    tableCell.accessoryType =  (self.systemSoundSelectedIndex == indexPath.row ) ?  UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return tableCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.systemSoundSelectedIndex = (int)indexPath.row;
    if (indexPath.row != 0) {
      
        NSString *path = self.systemSoundsArray[indexPath.row];
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"m4r"];
        
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL URLWithString:soundPath],&soundID);
        AudioServicesPlayAlertSound(soundID);

    }
    [soundListTableView reloadData];
}

#pragma mark
#pragma mark Sound Public Functions

// Index of the system selected sound
- (int)indexOfSoundSelected {
    
    int index = 0;
    if (self.userAlertSettings[@"sound"] != nil && [self.userAlertSettings[@"sound"] length] > 0) {
        index = (int)[self.systemSoundsArray indexOfObject:self.userAlertSettings[@"sound"]];
    }
    return index;
}

// Initialise array and add sounds
- (void)prepareSoundList {
    
    self.systemSoundsArray = [NSMutableArray array];
    [self.systemSoundsArray addObject:@"None"];
    [self.systemSoundsArray addObjectsFromArray:[EHHelpers arrayFromFile:@"Sounds.plist"]];
}

// Select sound for drug
- (IBAction)selectedAlarmSoundForDrug:(id)sender {
    
    [self showSoundList];
}

// Show the sound list view
- (void)showSoundList {
    
    soundListView.hidden = NO;
    [soundListTableView reloadData];

}

// Hide the sound list view
- (IBAction)hideSoundList:(id)sender {
    
    soundListView.hidden = YES;
    alarmSoundLabel.text = @"None";
    self.systemSoundSelectedIndex = 0;
    [soundListTableView reloadData];
}

// Add sound for the alert
- (IBAction)addSoundForAlert:(id)sender {

    soundListView.hidden = YES;
    alarmSoundLabel.text = (self.systemSoundSelectedIndex == 0) ? @"None": self.systemSoundsArray[self.systemSoundSelectedIndex];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"showDaysSelection"]){
        SelectDaysViewController *svc = (SelectDaysViewController *)[segue destinationViewController];
        svc.obj = self;
        svc.alertDays = [NSMutableDictionary dictionaryWithDictionary:self.alertDaysDict];
    }
}

#pragma mark
#pragma mark TextFieldDelegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self addKeyboardButtonToContainerScroll];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyBoardWhileTap];
    [textField resignFirstResponder];
    if (textField.text.length == 0) {
        drugHeaderField.text = [self drugName];
    }
    return YES;
}

@end
