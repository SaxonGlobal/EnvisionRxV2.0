//
//  AlarmListViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 8/6/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AlarmListViewController.h"
#import "Claims.h"
#import "Drugs.h"

@interface AlarmListViewController ()

@end

@implementation AlarmListViewController
@synthesize isEditing;
@synthesize drugInfo;
@synthesize alarmLists;

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
    
    self.screenName = @"Alarm List";
    self.selectedUserAlert = [NSDictionary dictionary];
    medTitleLabel.text = [self drugName];
    medTitleLabel2.text = [self drugName];;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserAlertsForDrug) name:@"AlertNotification" object:nil];
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isEditing = NO;
    editingHeaderView.hidden = YES;
    normalHeaderView.hidden = NO;
    noAlertsView.hidden = YES;
    [self loadUserAlertsForDrug];
}

// Logged in user member id
- (NSString*)memberIDKey {
    
    NSString *userMedString = @"";
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        userMedString =  [NSString stringWithFormat:@"%@_%@_%@",kUserAlerts,currentuser.email,[self drugName]];;
        ;;
    }
    return userMedString;
    
}

#pragma mark
#pragma mark Added alerts for the drug
// Saved alerts for the drug

- (NSArray *)savedUserAlerts {
    
    NSArray *alarms = [NSArray array];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        alarms = [userDefaults objectForKey:[self memberIDKey]];
    }
    return [alarms count] > 0 ? alarms : [NSArray array];
}

// Load user saved alerts for the drug
- (void)loadUserAlertsForDrug {
    
    NSArray *alarms = [self savedUserAlerts];
    if (alarms.count > 0 ) {
        self.alarmLists = [NSMutableArray arrayWithArray:[self updateAlertsStatus:alarms]];
    }
    [ self filterAlertsByTime ];
    [alarmListTableView reloadData];
    
}


#pragma mark
#pragma mark UpdateAlertStatus (Active/Inactive)
// Update the status of the alert if the repeat interval is never and the time has expired

- (NSArray*)updateAlertsStatus:(NSArray*)alertsArray {
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *alarm = [NSMutableArray array];
    
    
    NSString *drugAlertKey = @"";
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        
        
        drugAlertKey =  [NSString stringWithFormat:@"%@_%@_%@",kUserAlerts,currentuser.email,[self drugName]];;
        ;;
        if ([alertsArray count] > 0) {
            [alarm addObjectsFromArray:alertsArray];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        NSComparisonResult result;
        
        for (NSDictionary *dict in alertsArray) {
            
            
            if ([dict[@"repeat"] count] == 0) {

                
                NSDate *startDate = (NSDate*)dict[@"startDate"];
                result = [startDate compare:[NSDate date]]; // comparing two dates
                
                if(result == NSOrderedAscending){
                    
                    NSMutableDictionary *alarmDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    alarmDict[@"isActive"] = @(0);
                    
                    if ([alarm containsObject:dict]) {
                        [alarm removeObject:dict];
                    }
                    [alarm addObject:alarmDict];
                }
                
            }
            else if ([dict[@"endDate"] length] > 0) {
                
                NSString *endDateString = [NSString stringWithFormat:@"%@ %@",dict[@"endDate"],dict[@"alertTime"]];

                [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
                NSDate * endDate = [formatter dateFromString:endDateString];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSString *endDateFormattedString = [formatter stringFromDate:endDate];
                
                result = [[NSDate date] compare:[formatter dateFromString:endDateFormattedString]];
                if (result == NSOrderedDescending || result == NSOrderedSame) {
                  
                    NSMutableDictionary *alarmDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    alarmDict[@"isActive"] = @(0);
                    
                    if ([alarm containsObject:dict]) {
                        [alarm removeObject:dict];
                    }
                    [alarm addObject:alarmDict];
                }
            }
            
        }
        if ([alarm count] > 0) {
            [userDefaults setObject:[NSArray arrayWithArray:alarm] forKey:drugAlertKey];
        }
    }
    return alarm.count > 0 ? [NSArray arrayWithArray:alarm] : [NSArray array];
}

// Drug Name
- (NSString*)drugName {
    BOOL manualDrug = ![self.drugInfo isKindOfClass:[Claims class]];
    if (manualDrug) {
        return self.drugInfo[@"drugName"];
    }
    Claims *claimObj = (Claims *)self.drugInfo;
    return claimObj.drug.proddescabbrev;
}

#pragma mark 
#pragma mark Edit Alarm
// Edit User Added alarm
- (IBAction)editAlarm:(id)sender {
    
    editingHeaderView.hidden = NO;
    normalHeaderView.hidden = YES;
    self.isEditing = YES;
    [alarmListTableView reloadData];
    
}

- (IBAction)didCompleteEditing:(id)sender {
    
    editingHeaderView.hidden = YES;
    normalHeaderView.hidden = NO;
    self.isEditing = NO;
    self.selectedUserAlert = nil;
    [alarmListTableView reloadData];
    
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.alarmLists count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlarmCell *alarmCell = (AlarmCell *)[tableView dequeueReusableCellWithIdentifier:@"alarmCellIdentifier"];
    if (!alarmCell) {
        alarmCell = [[[NSBundle mainBundle] loadNibNamed:@"AlarmCell" owner:self options:nil] objectAtIndex:0];
    }
    
    NSDictionary *alarm = self.alarmLists[indexPath.row];
    
    alarmCell.rightArrow.hidden = self.isEditing == YES ? NO : YES;
    alarmCell.deleteButton.hidden = self.isEditing == YES ? NO : YES;
    alarmCell.alarmSwitch.hidden = self.isEditing == YES ? YES : NO;
    [alarmCell.alarmSwitch setOn:[alarm[@"isActive"]boolValue]]   ;
    
    
    alarmCell.alarmSwitch.tag = indexPath.row;
    [alarmCell.alarmSwitch addTarget:self action:@selector(switchOffOrOn:) forControlEvents:UIControlEventTouchUpInside];
    
    alarmCell.deleteButton.tag =indexPath.row;
    [alarmCell.deleteButton addTarget:self action:@selector(deleteAlarm:) forControlEvents:UIControlEventTouchUpInside];
    
    alarmCell.timeLabel.attributedText = [self attributeStringForAlarmList:alarm[@"alertTime"]];
    alarmCell.timeStatusLabel.text = @"AM";
    alarmCell.repeatLabel.text = [EHHelpers repeatStatusForDrug:alarm[@"repeat"]];
    alarmCell.timeXOriginConstraint.constant = self.isEditing == YES ? 48 : 0;
    alarmCell.editingOptionsButton.tag = indexPath.row;
    [alarmCell.editingOptionsButton addTarget:self action:@selector(editUserAlert:) forControlEvents:UIControlEventTouchUpInside];
    
    return alarmCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

// Show alert settings page to edit the selected alarm setting
- (void)editUserAlert:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (self.isEditing == YES) {
        self.selectedUserAlert = [NSDictionary dictionaryWithDictionary:self.alarmLists[btn.tag]];
        [self performSegueWithIdentifier:@"addNewAlert" sender:nil];
    }
}

#pragma mark
// Customise the font structure

- (NSAttributedString*)attributeStringForAlarmList:(NSString*)alarmString{
    
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:alarmString];
    NSInteger stringLength=[alarmString length];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:29]
                      range:NSMakeRange( 0,5 )];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:12]
                      range:NSMakeRange(5, [alarmString length] - 5)];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:37.0/255.0 green:77.0/255.0 blue:110.0/255.0 alpha:1.0] range:NSMakeRange(0, stringLength)];
    
    return attString;
}

#pragma mark
#pragma mark Delete alert
// Delete user added alerts
- (void)deleteAlarm:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    NSArray *userAlerts = [self savedUserAlerts];
    
    NSDictionary *drug = self.alarmLists[btn.tag];
    [self.alarmLists removeObjectAtIndex:btn.tag];
    userAlerts = [NSArray arrayWithArray:self.alarmLists];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSArray arrayWithArray:userAlerts] forKey:[self memberIDKey]];
    [userDefaults synchronize];
    [self filterAlertsByTime];
    [AlertHandler removeNotificationByIDForDrug:drug];
    [alarmListTableView reloadData];
}


#pragma mark
#pragma mark Toggle alert
// Toggle on/off for the user added alerts
- (void)switchOffOrOn:(id)sender {
    
    UISwitch *toggleSwitch = (UISwitch*)sender;
    
    NSArray *userAlerts = [self savedUserAlerts];
    NSMutableDictionary *drug =    [NSMutableDictionary dictionaryWithDictionary:self.alarmLists[toggleSwitch.tag]];
    drug[@"isActive"] = [NSNumber numberWithBool:toggleSwitch.isOn];
    [self.alarmLists replaceObjectAtIndex:toggleSwitch.tag withObject:drug];
    
    userAlerts = self.alarmLists;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSArray arrayWithArray:userAlerts] forKey:[self memberIDKey]];
    [userDefaults synchronize];
    
    [self filterAlertsByTime];
    
    if ([drug[@"isActive"] boolValue] == NO) {
        [AlertHandler removeNotificationByIDForDrug:drug];
    }
    else{
        [self scheduleNotification:drug];
    }
    [alarmListTableView reloadData];
}

#pragma mark
#pragma mark Filter Alert By Time
// Filter alerts by time
- (void)filterAlertsByTime {
    noAlertsView.hidden = YES;
    
    if ([self.alarmLists count] > 0) {
        [AlertHandler filterAlertsByTime:self.alarmLists];
    }
    if ([self.alarmLists count] == 0) {
        noAlertsView.hidden = NO;
    }
}

#pragma mark
#pragma mark Schedule Notification
// Schedule notification for the drug
- (void)scheduleNotification:(NSDictionary*)drug {
    
    NSArray *repeatDayOrdinals = [AlertHandler getRepeatOrdinalsForDrug:drug];
    
    NSTimeInterval time = floor([drug[@"startDate"] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    //If no repeat or repeat all days, schedule using iOS available repeat counts
    
    if ([repeatDayOrdinals count] == 0 || [repeatDayOrdinals count] == 7) {
        
        //check if selected time expired today, if so, schedule for tomorrow
        if ([[NSDate date] compare:currentDate] != NSOrderedAscending) {
            //add 1 day = 24hrs * 60 mins * 60 seconds
            currentDate = [currentDate dateByAddingTimeInterval:DAY_IN_SECONDS];
        }
        [AlertHandler scheduleNotificationForDate:currentDate withDrugInfo:drug];
    }
    else { //schedule seperate notification for each day
        
        NSDate *initialDate = currentDate;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit fromDate:initialDate];
        NSUInteger weekdayToday = [components weekday];
        
        for (id obj in repeatDayOrdinals) {
            
            NSInteger daysToTarget =  weekdayToday - [obj intValue];
            if (daysToTarget < 0) {
                daysToTarget += 7;
            }
            
            NSDate *followingTargetDay = [initialDate dateByAddingTimeInterval:DAY_IN_SECONDS*daysToTarget];
            [AlertHandler scheduleNotificationForDate:followingTargetDay withDrugInfo:drug];

        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Show alert setting page
- (IBAction)addNewAlert:(id)sender {
    
    [self performSegueWithIdentifier:@"addNewAlert" sender:nil];
    
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"addNewAlert"]){
        SetAlarmViewController *svc = (SetAlarmViewController *)[segue destinationViewController];
        svc.drugDict = self.drugInfo;
        svc.userAlertSettings = (self.isEditing == YES) ? [NSMutableDictionary dictionaryWithDictionary:self.selectedUserAlert] : [NSMutableDictionary dictionary];
    }
}
@end
