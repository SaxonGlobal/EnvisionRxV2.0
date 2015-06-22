//
//  Drugs.h
//  Envisionrx
//
//  Created by Nithin Nizam on 10/8/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Claims;

@interface Drugs : NSManagedObject

@property (nonatomic, retain) NSString * gpi;
@property (nonatomic, retain) NSString * multisource;
@property (nonatomic, retain) NSString * ndc;
@property (nonatomic, retain) NSNumber * otc;
@property (nonatomic, retain) NSString * proddescabbrev;
@property (nonatomic, retain) NSNumber * strength;
@property (nonatomic, retain) Claims *claim;

@end
