//
//  EHOperation.m
//  Envisionrx
//
//  Created by Nassif on 20/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "EHOperation.h"

@implementation EHOperation


- (id)initWithDelegate:(NSObject<EHOperationProtocol> *)obj {
    self = [super init];
    if (self != nil) {
        self.delegateObj = obj;
    }
    return self;
}

- (void)soapWebServiceWithBody:(NSString *)soapBody soapAction:(NSString *)soapAction andCompletionSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@%@", API_ROOT, API_HOST_PATH]];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapBody length]];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    @try {
        self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
        [self.operation setCompletionBlockWithSuccess:success failure:failure];
        [self.operation start];
        
    }
    @catch (NSException *exception) {
        //Create a dictionary with the data we want to send
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
        //call the notifier with both parameters
        [Bugsnag notify:exception withData:data];
    }
    @finally {
        
    }
}

#pragma mark
#pragma mark Security Questions

- (void)loadSecurityQuestionsWithSoapBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *securityQuestions = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"SecurityQuestion"] error:nil];
            [self.delegateObj successFullyLoadedSecurityQuestionData:securityQuestions];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}

#pragma mark
#pragma mark Login

- (void)loginUserWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *loginInfo = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"UserLoginResult"] error:nil];
            [self.delegateObj successfullyLoggedIn:loginInfo];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
}


#pragma mark
#pragma mark Forgot Password

- (void)retrievePasswordDetailsWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *passwordData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"PasswordRetrievalResult"] error:nil];
            [self.delegateObj successfullyRequestedForgotPassword:passwordData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}

#pragma mark
#pragma mark Alternative Drug

- (void)fetchAlternativeDrugWithBody:(NSString *)body forAction:(NSString *)action{
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *alternativeDrug = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"Drug"] error:nil];
            [self.delegateObj successFullyFetchedAlternativeDrug:alternativeDrug];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}

#pragma mark
#pragma mark DrugPricingByNABP

- (void)fetchDrugPricingByNABPWithBody:(NSString *)body forAction:(NSString *)action withNDC:(NSString*)ndc{
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *pricingData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetDrugPricingByNABPResult"] error:nil];
            [self.delegateObj successFUllyReceivedPricingData:pricingData withNDC:ndc];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
    
}


#pragma mark
#pragma mark FAQ

- (void)fetchFAQWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *faqData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"FAQ"] error:nil];
            [self.delegateObj successFullyFetchedFAQData:faqData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}

#pragma mark
#pragma mark PurchasedPharmacy Details
- (void)fetchPurchasedPharmacyInfoWithBody:(NSString *)body forAction:(NSString *)action{
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *pharmacyData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetPharmacyByNABPResult"] error:nil];
            [self.delegateObj successfullyFetchedPurchasedPharmacyData:pharmacyData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}

#pragma mark
#pragma mark MultisourceLikelySavings

- (void)fetchMultisourceLikelySavingsDataWithBody:(NSString *)body forAction:(NSString *)action withClaimHistory:(Claims *)userClaim {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *savingsData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetGenericEquivalentByBrandNDCResult"] error:nil];
            [self.delegateObj successFullyFetchedMultiSourceSavingsData:savingsData withClaimHistory:userClaim];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
}

#pragma mark
#pragma mark FindCare

- (void)findCareWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *careData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"EnvisionPharmacy"] error:nil];
            [self.delegateObj successFullyFetchedCareData:careData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
}

#pragma mark
#pragma mark UserClaims

- (void)fetchUserClaimsWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *userClaims = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"Claim"] error:nil];
            [self.delegateObj successfullyfetchedUserClaimsData:userClaims];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}

#pragma mark
#pragma mark UserProfile

- (void)updateUserProfileWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *profileData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"UpdateMemberAccountResult"] error:nil];
            [self.delegateObj successfullyUpdatedUserProfile:profileData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];

}

#pragma mark
#pragma mark UserRegistration

- (void)registerUserWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *newUserData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"UserRegistrationResult"] error:nil];
            [self.delegateObj successFullyRegistered:newUserData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];

}

#pragma mark
#pragma mark 

- (void)loadTermsAndConditionsWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *termsData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetTermsAndConditionsResult"] error:nil];
            [self.delegateObj successfullyLoadedTermsAndConditions:termsData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];

}

#pragma mark
#pragma mark PlanOverView

- (void)fetchPlanOverviewWithBody:(NSString*)body forAction:(NSString*)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *planOverView = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetPlanOverviewResult"] error:nil];
            [self.delegateObj successFullyReceivedPlanOverView:planOverView];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];

}

#pragma mark
#pragma mark Supported Version

- (void)getSupportedVersion {
    
    NSString *soapAction = [NSString stringWithFormat:@"%@/GetSupportedVersion", API_ACTION_ROOT];
    NSString *soapBodyXML = [NSString stringWithFormat:EHSupportedVersion, AppID] ;
    NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
    [self  soapWebServiceWithBody:soapBody soapAction:soapAction andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *supportCheckData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetSupportedVersionResult"] error:nil];
            [self.delegateObj successfullyRetrievedSupportVersionCheckData:supportCheckData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       // [self.delegateObj error:error];
    }];

}

#pragma mark
#pragma mark PricingByLocation

- (void)fetchPricingByLocationWithBody:(NSString *)body forAction:(NSString *)action{
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *pricingData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetDrugPricingByLatLongResult"] error:nil];
            [self.delegateObj successfullyFetchedPricingDataByLatOrZipCode:pricingData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
    
}


#pragma mark
#pragma mark PricingByZipCode

- (void)fetchPricingByZipCodeWithBody:(NSString *)body forAction:(NSString *)action {
    
    [self  soapWebServiceWithBody:body soapAction:action andCompletionSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSError *error = nil;
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            NSArray *pricingData = [doc nodesForXPath:[NSString stringWithFormat:XML_CUSTOM_XPATH, @"GetDrugPricingByZipcodeResult"] error:nil];
            [self.delegateObj successfullyFetchedPricingDataByLatOrZipCode:pricingData];
        }
        @catch (NSException *exception) {
            //Create a dictionary with the data we want to send
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[exception description], @"exception", nil];
            //call the notifier with both parameters
            [Bugsnag notify:exception withData:data];
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegateObj error:error];
    }];
}
#pragma mark
#pragma mark Cancel

- (void)cancelOp {
    
    [self.operation cancel];
}
@end
