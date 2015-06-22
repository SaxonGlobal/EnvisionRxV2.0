//
//  Pharmacy.h
//  Envisionrx
//
//  Created by Nassif on 04/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pharmacy : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nabp;
@property (nonatomic, retain) NSString * sAddress;
@property (nonatomic, retain) NSString * pAddress;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * lat;
@property (nonatomic, retain) NSString * lon;
@property (nonatomic, retain) NSString * distance;
@property (nonatomic, retain) NSString * dispType;
@property (nonatomic, retain) NSString * dispClass;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * monHrs;
@property (nonatomic, retain) NSString * tueHrs;
@property (nonatomic, retain) NSString * wedHrs;
@property (nonatomic, retain) NSString * thuHrs;
@property (nonatomic, retain) NSString * friHrs;
@property (nonatomic, retain) NSString * satHrs;
@property (nonatomic, retain) NSString * sunHrs;
@property (nonatomic, retain) NSString * retail;
@property (nonatomic, retain) NSString * vaccNetwork;
@property (nonatomic, retain) NSString * affiliationCode;

@end
