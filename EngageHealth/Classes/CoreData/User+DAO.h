//
//  User+DAO.h
//  Envisionrx
//
//  Created by Nassif on 19/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "User.h"
#import "Constants.h"
#import "EHHelpers.h"

@interface User (DAO)

+ (void)createUserWithLoginInfo:(DDXMLElement*)loginData withUserEmail:(NSString*)userEmail withPassword:(NSString*)password;
+ (User*)populateUserObjectWithData:(DDXMLElement *)loginData onUserObj:(User *)userObj withPassword:(NSString*)password;
+ (NSArray*)userInfoIfAvailableForUser:(NSString*)userEmail;
+ (void)loginUserWithInfo:(DDXMLElement*)loginData withUserEmail:(NSString*)userEmail withPassword:(NSString*)password;
- (NSArray*)currentUserClaims;
@end
