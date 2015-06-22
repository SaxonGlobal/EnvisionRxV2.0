//
//  Claims.h
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AlternateDrug, Drugs, Pharmacy, User;

@interface Claims : NSManagedObject

@property (nonatomic, retain) NSNumber * daysSupply;
@property (nonatomic, retain) NSDate * fillDate;
@property (nonatomic, retain) NSNumber * memberPaid;
@property (nonatomic, retain) NSString * pharmacyId;
@property (nonatomic, retain) NSNumber * planPaid;
@property (nonatomic, retain) NSString * prescriberId;
@property (nonatomic, retain) NSString * prescriberName;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSDate * renewalDate;
@property (nonatomic, retain) NSNumber * renewalDays;
@property (nonatomic, retain) NSString * rxNumber;
@property (nonatomic, retain) NSNumber * totalPaid;
@property (nonatomic, retain) Drugs *drug;
@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *alternateDrug;
@end

@interface Claims (CoreDataGeneratedAccessors)

- (void)addAlternateDrugObject:(AlternateDrug *)value;
- (void)removeAlternateDrugObject:(AlternateDrug *)value;
- (void)addAlternateDrug:(NSSet *)values;
- (void)removeAlternateDrug:(NSSet *)values;

@end
