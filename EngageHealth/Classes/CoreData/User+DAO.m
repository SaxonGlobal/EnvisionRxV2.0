//
//  User+DAO.m
//  Envisionrx
//
//  Created by Nassif on 19/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "User+DAO.h"

@implementation User (DAO)

+ (void)createUserWithLoginInfo:(DDXMLElement*)loginData withUserEmail:(NSString*)userEmail withPassword:(NSString*)password{
    
    NSManagedObjectContext *const ctx = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *getItem = [NSFetchRequest
                               fetchRequestWithEntityName:[User entityName]];
    
    getItem.predicate = [NSPredicate
                         predicateWithFormat:@"email == %@", userEmail];
    __block NSArray *matchingItems = [ctx executeFetchRequest:getItem
                                                        error:nil];
    User *user = nil;
    if (matchingItems.count > 0) {
        user = [matchingItems objectAtIndex:0];
        [ctx deleteObject:user];
        
    }
    
    user = [NSEntityDescription insertNewObjectForEntityForName:[User entityName] inManagedObjectContext:ctx];
    user = [[self class] populateUserObjectWithData:loginData onUserObj:user withPassword:password];
    [APP_DELEGATE setCurrentUser:user];
    [ctx save:nil];
    
}

+ (void)loginUserWithInfo:(DDXMLElement*)loginData withUserEmail:(NSString*)userEmail withPassword:(NSString*)password {
   
    NSManagedObjectContext *const ctx = [APP_DELEGATE managedObjectContext];

    NSArray *matchingItems = [self userInfoIfAvailableForUser:userEmail];
    User *user = nil;
    if (matchingItems.count > 0) {
        user = [matchingItems objectAtIndex:0];
    }
    else{
        user = [NSEntityDescription insertNewObjectForEntityForName:[User entityName] inManagedObjectContext:ctx];

    }
    user = [[self class] populateUserObjectWithData:loginData onUserObj:user withPassword:password];
    [APP_DELEGATE setCurrentUser:user];
    [ctx save:nil];

}



+ (NSArray*)userInfoIfAvailableForUser:(NSString*)userEmail {
    
    NSManagedObjectContext *const ctx = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *getItem = [NSFetchRequest
                               fetchRequestWithEntityName:[User entityName]];
    
    getItem.predicate = [NSPredicate
                         predicateWithFormat:@"email == %@", userEmail];
    __block NSArray *matchingItems = [ctx executeFetchRequest:getItem
                                                        error:nil];
    return matchingItems;
    
}
+ (User*)populateUserObjectWithData:(DDXMLElement *)loginData onUserObj:(User *)userObj withPassword:(NSString*)password {
    
    [userObj setMemberId:[EHHelpers xmlElementValueForKey:@"MemberID" forXmlElement:loginData]];
    [userObj setAccountId:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"AccountID" forXmlElement:loginData] intValue]]];
    [userObj setGroupId:[EHHelpers xmlElementValueForKey:@"GroupID" forXmlElement:loginData]];
    [userObj setFirstName:[EHHelpers xmlElementValueForKey:@"FirstName" forXmlElement:loginData]];
    [userObj setLastName:[EHHelpers xmlElementValueForKey:@"LastName" forXmlElement:loginData]];
    [userObj setPersonCode:[EHHelpers xmlElementValueForKey:@"PersonCode" forXmlElement:loginData]];
    [userObj setCarrier:[EHHelpers xmlElementValueForKey:@"Carrier" forXmlElement:loginData]];
    [userObj setZipCode:[EHHelpers xmlElementValueForKey:@"ZipCode" forXmlElement:loginData]];
    [userObj setGuid:[EHHelpers xmlElementValueForKey:@"GUID" forXmlElement:loginData]];
    [userObj setEmail:[EHHelpers xmlElementValueForKey:@"Email" forXmlElement:loginData]];
    [userObj setBin:[EHHelpers xmlElementValueForKey:@"BIN" forXmlElement:loginData]];
    [userObj setPcn:[EHHelpers xmlElementValueForKey:@"PCN" forXmlElement:loginData]];
    [userObj setMemberHelp:[EHHelpers xmlElementValueForKey:@"MemberHelp" forXmlElement:loginData]];
    [userObj setPharmacyHelp:[EHHelpers xmlElementValueForKey:@"PharmacyHelp" forXmlElement:loginData]];
    [userObj setLogoUrl:[EHHelpers xmlElementValueForKey:@"LogoURL" forXmlElement:loginData]];
    [userObj setDob:[EHHelpers xmlElementValueForKey:@"DOB" forXmlElement:loginData]];
    [userObj setPassword:password];
    [userObj setRelationId:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"RelationID" forXmlElement:loginData] intValue]]];
    [userObj setGender:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"Gender" forXmlElement:loginData] intValue]]];
    [userObj setPhone:[EHHelpers xmlElementValueForKey:@"Phone" forXmlElement:loginData]];
    [userObj setQuestion:[EHHelpers xmlElementValueForKey:@"Question" forXmlElement:loginData]];
    [userObj setQuestionId:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"QuestionID" forXmlElement:loginData] intValue]]];
    [userObj setPharmacy:[EHHelpers xmlElementValueForKey:@"Pharmacy" forXmlElement:loginData]];
    [userObj setPharmacyName:[EHHelpers xmlElementValueForKey:@"PharmacyName" forXmlElement:loginData]];
    [userObj setChainCode:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"ChainCode" forXmlElement:loginData] intValue]]];
    [userObj setMailOrderId:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"MailOrderID" forXmlElement:loginData] intValue]]];
    
    [userObj setMailOrderNABP:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"MailOrderNABP" forXmlElement:loginData] intValue]]];
    [userObj setHouseHoldFlag:[NSNumber numberWithInt:[[EHHelpers xmlElementValueForKey:@"MailOrderNABP" forXmlElement:loginData] intValue]]];
    [userObj setEnabled:[NSNumber numberWithBool:[[EHHelpers xmlElementValueForKey:@"Enabled" forXmlElement:loginData] boolValue]]];
    [userObj setSso:[NSNumber numberWithBool:[[EHHelpers xmlElementValueForKey:@"SSO" forXmlElement:loginData] boolValue]]];
    
    return userObj;
}

- (NSArray*)currentUserClaims {
    
    NSString *minimumClaimsInterval = [EHHelpers loadDefaultSettingsForKey:@"claimsInterval" withDefaultValue:DefaultClaimsInterval] ;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"fillDate" ascending:NO];
    NSDate *currentDate = [NSDate date];
    NSDate *startDate = [NSDate dateWithTimeInterval:- (MONTH_IN_SECONDS*minimumClaimsInterval.intValue) sinceDate:currentDate];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fillDate >= %@) AND (fillDate <= %@)", startDate, currentDate];
    NSArray *claimsHistory = [NSArray arrayWithArray:[[[self.claim filteredSetUsingPredicate:predicate] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];

    return claimsHistory;
}
@end
