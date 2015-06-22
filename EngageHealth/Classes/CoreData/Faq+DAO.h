//
//  Faq+DAO.h
//  Envisionrx
//
//  Created by Nassif on 19/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "Faq.h"
#import "Constants.h"

@interface Faq (DAO)

+ (void)prepareFaqData:(NSArray*)dataElement;
+ (Faq*)insertFaqElement:(DDXMLElement*)dataElement;
+ (void)removeFaqDataForUser;
+ (Faq*)populateObjectWithElement:(DDXMLElement*)dataElement onObj:(Faq*)faqObj;
+ (NSArray*)allFaqDataForCurrentUser;

@end
