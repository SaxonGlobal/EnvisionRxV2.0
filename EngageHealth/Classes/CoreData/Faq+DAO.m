//
//  Faq+DAO.m
//  Envisionrx
//
//  Created by Nassif on 19/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "Faq+DAO.h"

@implementation Faq (DAO)

+ (NSArray*)allFaqDataForCurrentUser {
    
    User *currentUser = [APP_DELEGATE currentUser];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    NSArray *faqList = [[currentUser.faq  allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    return faqList;
}

+ (void)removeFaqDataForUser {
   
    NSError *error = nil;
    NSManagedObjectContext *const ctx = [APP_DELEGATE managedObjectContext];
    NSArray *faqData = [[self class] allFaqDataForCurrentUser];
    for (Faq *faqObject in faqData) {
        [[APP_DELEGATE currentUser] removeFaqObject:faqObject];
        [ctx deleteObject:faqObject];
    }
    [ctx save:&error];
    
}

+ (void)prepareFaqData:(NSArray *)dataElement{
    
    [[self class] removeFaqDataForUser];
    
    for (DDXMLElement *faqData in dataElement) {
        [[self class] insertFaqElement:faqData];
    }
}

+ (Faq*)insertFaqElement:(DDXMLElement *)dataElement {
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    Faq *obj = [NSEntityDescription insertNewObjectForEntityForName:[Faq entityName] inManagedObjectContext:context];
    
    obj = [[self class] populateObjectWithElement:dataElement onObj:obj];
    [[APP_DELEGATE currentUser] addFaqObject:obj];


    NSError *error;
    if (![context save:&error]) {
        NSLOG(@"Error in inserting Drug Object - error:%@" ,error);
    }
    
    return obj;

}

+ (Faq*)populateObjectWithElement:(DDXMLElement*)dataElement onObj:(Faq*)faqObj{
   
    [faqObj setQuestion:[EHHelpers xmlElementValueForKey:@"Question" forXmlElement:dataElement]];
    [faqObj setAnswer:[EHHelpers xmlElementValueForKey:@"Answer" forXmlElement:dataElement]];
    [faqObj setSortOrder:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"Order" forXmlElement:dataElement] intValue]]];
    [faqObj setUser:[APP_DELEGATE currentUser]];
    return faqObj;
}
@end
