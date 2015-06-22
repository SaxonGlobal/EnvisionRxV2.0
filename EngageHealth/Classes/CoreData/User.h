//
//  User.h
//  Envisionrx
//
//  Created by Nassif on 10/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Claims, Faq;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSString * bin;
@property (nonatomic, retain) NSString * carrier;
@property (nonatomic, retain) NSNumber * chainCode;
@property (nonatomic, retain) NSString * dob;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * houseHoldFlag;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * logoUrl;
@property (nonatomic, retain) NSNumber * mailOrderId;
@property (nonatomic, retain) NSNumber * mailOrderNABP;
@property (nonatomic, retain) NSString * memberHelp;
@property (nonatomic, retain) NSString * memberId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * pcn;
@property (nonatomic, retain) NSString * personCode;
@property (nonatomic, retain) NSString * pharmacy;
@property (nonatomic, retain) NSString * pharmacyHelp;
@property (nonatomic, retain) NSString * pharmacyName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSNumber * questionId;
@property (nonatomic, retain) NSNumber * relationId;
@property (nonatomic, retain) NSNumber * sso;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSSet *claim;
@property (nonatomic, retain) NSSet *faq;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addClaimObject:(Claims *)value;
- (void)removeClaimObject:(Claims *)value;
- (void)addClaim:(NSSet *)values;
- (void)removeClaim:(NSSet *)values;

- (void)addFaqObject:(Faq *)value;
- (void)removeFaqObject:(Faq *)value;
- (void)addFaq:(NSSet *)values;
- (void)removeFaq:(NSSet *)values;

@end
