//
//  Faq.h
//  Envisionrx
//
//  Created by Nassif on 10/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Faq : NSManagedObject

@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) User *user;

@end
