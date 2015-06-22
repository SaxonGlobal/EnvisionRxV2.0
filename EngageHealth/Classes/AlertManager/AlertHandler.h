//
//  AlertHandler.h
//  Envisionrx
//
//  Created by Nassif on 13/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface AlertHandler : NSObject

+ (NSString*)memberIDKey:(NSString*)drugName;
+ (NSArray *)savedUserAlerts:(NSString*)drugName;
+ (BOOL)hasAnyActiveAlertsForDrug:(NSString*)drugName;
+ (void)removeNotificationForManualDrug:(NSString*)manualDrug;
+ (void)removeNotificationByIDForDrug:(NSDictionary *)drug ;
+ (NSArray*)updateStatusForAlerts:(NSArray*)alerts;
+ (NSArray*)getRepeatOrdinalsForDrug:(NSDictionary*)drug;
+ (void)scheduleNotificationForDate:(NSDate*)alertDate withDrugInfo:(NSDictionary*)drugDetails;
+ (void)filterAlertsByTime:(NSMutableArray*)alerts;
+ (void)deleteExpiredNotifications;
+ (void)checkIfAppHasPreviousNotification;
@end
