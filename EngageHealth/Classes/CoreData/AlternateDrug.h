//
//  AlternateDrug.h
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Claims;

@interface AlternateDrug : NSManagedObject

@property (nonatomic, retain) NSString * copay;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ndc;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * savings;
@property (nonatomic, retain) Claims *claim;

@end
