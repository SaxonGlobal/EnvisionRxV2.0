//
//  AlertHandler.m
//  Envisionrx
//
//  Created by Nassif on 13/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AlertHandler.h"

@implementation AlertHandler
// Logged in user member id
+ (NSString*)memberIDKey:(NSString*)drugName {
    
    NSString *userMedString = @"";
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        
        userMedString =  [NSString stringWithFormat:@"%@_%@_%@",kUserAlerts, currentuser.email,drugName];;
        ;;
    }
    return userMedString;
    
}

// Saved alerts for the drug
+ (NSArray *)savedUserAlerts:(NSString*)drugName {
    
    NSArray *alarms = [NSArray array];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        alarms = [userDefaults objectForKey:[self memberIDKey:drugName]];
    }
    
    return [alarms count] > 0 ? alarms : [NSArray array];
}

// Check if a drug has an active alert
+ (BOOL)hasAnyActiveAlertsForDrug:(NSString*)drugName {
    
    NSArray *alertsForDrug = [self savedUserAlerts:drugName];
    
    BOOL hasActiveAlerts = NO;
    
    for (NSDictionary *alert in alertsForDrug) {
        if (alert[@"isActive"] != nil && [alert[@"isActive"] intValue] == 1) {
            hasActiveAlerts = YES;
            break;
        }
    }
    return hasActiveAlerts;
}


// Remove the notification for the manual drug
+ (void)removeNotificationForManualDrug:(NSString*)manualDrug {
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"name"] isEqualToString:manualDrug]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
}

+ (void)removeNotificationByIDForDrug:(NSDictionary *)drug {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"alarmId"]];
        if ([uid isEqualToString:drug[@"alarmId"]])
        {
            [app cancelLocalNotification:oneEvent];
        }
    }
    
}
+ (NSArray*)updateStatusForAlerts:(NSArray*)alerts{
    
    NSMutableArray *alarm = [NSMutableArray array];
    
    if ([alerts count] > 0) {
        [alarm addObjectsFromArray:alerts];
    }
    
    NSDateFormatter *alertFormatter = [[NSDateFormatter alloc] init];
    
    NSComparisonResult result;
    
    for (NSDictionary *dict in alerts) {
        
        
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
            
            [alertFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
            NSDate * endDate = [alertFormatter dateFromString:endDateString];
            [alertFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            NSString *endDateFormattedString = [alertFormatter stringFromDate:endDate];
            
            result = [[NSDate date] compare:[alertFormatter dateFromString:endDateFormattedString]];
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
    return alarm.count > 0 ? [NSArray arrayWithArray:alarm] : [NSArray array];
    
}

+ (void)scheduleNotificationForDate:(NSDate *)alertDate withDrugInfo:(NSDictionary *)drugDetails {
    
    NSString *medicineString = [drugDetails[@"customheader"] length] > 0 ? drugDetails[@"customheader"] : drugDetails[@"name"];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = alertDate;
    localNotification.alertBody = [NSString stringWithFormat:kNotificationMessage, medicineString];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = drugDetails;
    localNotification.soundName = (drugDetails[@"sound"] != nil  && [drugDetails[@"sound"] length] > 0) ? [NSString stringWithFormat:@"%@.m4r", drugDetails[@"sound"]] : UILocalNotificationDefaultSoundName;
    
    if ([[[self class] getRepeatOrdinalsForDrug:drugDetails] count] == 7) {
        localNotification.repeatInterval = NSCalendarUnitDay;
    }
    else if ([[[self class] getRepeatOrdinalsForDrug:drugDetails] count] == 0){
        localNotification.repeatInterval = 0;
    }
    else{
        localNotification.repeatInterval = NSCalendarUnitWeekday;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}

+ (NSArray*)getRepeatOrdinalsForDrug:(NSDictionary*)drug{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (id obj in [drug[@"repeat"] allKeys]) {
        if ([[drug[@"repeat"] objectForKey:obj] intValue] == 1) {
            [tempArray addObject:obj];
        }
    }
    
    return tempArray;
}

+ (void)filterAlertsByTime:(NSMutableArray*)alerts {
    
    NSDateFormatter *currentDateFormattter = [[NSDateFormatter alloc] init];
    [currentDateFormattter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *currentDateString = [currentDateFormattter stringFromDate:[NSDate date]];
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    [alerts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [hourFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",currentDateString,obj1[@"alertTime"]]];
        NSDate *date2 =[hourFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",currentDateString, obj2[@"alertTime"]]] ;
        
        
        return [date1 compare:date2];
        
    }];
}

+ (void)deleteExpiredNotifications {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        
        if (notification.userInfo[@"endDate"] != nil) {
            
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *endDateString = [formatter stringFromDate:[NSDate date]];
            
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
            NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",endDateString,notification.userInfo[@"endDate"]]];
            
            
            
            NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
            NSDate *currentDate = [formatter dateFromString:currentDateString];
            NSTimeInterval timeINtveral = [endDate timeIntervalSinceDate:currentDate];
            if (timeINtveral < 0) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
            
        }
    }
    
}

+ (void)checkIfAppHasPreviousNotification {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kNotificationAlert] ){
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNotificationAlert];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

@end
