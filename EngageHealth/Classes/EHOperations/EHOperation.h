//
//  EHOperation.h
//  ;
//
//  Created by Nassif on 20/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Claims.h"
#import "AFNetworking.h"
#import "Constants.h"

@protocol EHOperationProtocol <NSObject>

@optional
- (void)successFullWithDelegate:(NSArray*)data;
- (void)successFullyLoadedSecurityQuestionData:(NSArray*)data;
- (void)successfullyLoggedIn:(NSArray*)loginData;
- (void)successfullyRequestedForgotPassword:(NSArray*)data;
- (void)successFullyFetchedAlternativeDrug:(NSArray*)alternative;
- (void)successFUllyReceivedPricingData:(NSArray*)pricingData withNDC:(NSString*)ndc;
- (void)successFullyFetchedFAQData:(NSArray*)faqData;
- (void)successfullyFetchedPurchasedPharmacyData:(NSArray*)data;
- (void)successFullyFetchedMultiSourceSavingsData:(NSArray*)data withClaimHistory:(Claims*)claim;
- (void)successFullyFetchedCareData:(NSArray*)data;
- (void)successfullyfetchedUserClaimsData:(NSArray*)data;
- (void)successfullyUpdatedUserProfile:(NSArray*)data;
- (void)successFullyRegistered:(NSArray*)newUserData;
- (void)successfullyLoadedTermsAndConditions:(NSArray*)data;
- (void)successFullyReceivedPlanOverView:(NSArray*)data;
- (void)successfullyFetchedPricingDataByLatOrZipCode:(NSArray*)data;
- (void)successfullyRetrievedSupportVersionCheckData:(NSArray*)data;
- (void)successfullyFetchedPricingDataByNABP:(NSArray*)data;
- (void)error:(NSError*)operationError;
@end

@interface EHOperation : NSObject

@property (nonatomic ,strong) AFHTTPRequestOperation *operation;
@property (nonatomic ,strong) NSObject<EHOperationProtocol>*delegateObj;

- (id)initWithDelegate:(NSObject<EHOperationProtocol>*)obj;

- (void)loadSecurityQuestionsWithSoapBody:(NSString*)body forAction:(NSString*)action;
- (void)loginUserWithBody:(NSString*)body forAction:(NSString*)action;
- (void)retrievePasswordDetailsWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchAlternativeDrugWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchDrugPricingByNABPWithBody:(NSString *)body forAction:(NSString *)action withNDC:(NSString*)ndc;
- (void)fetchFAQWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchPurchasedPharmacyInfoWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchMultisourceLikelySavingsDataWithBody:(NSString*)body forAction:(NSString*)action withClaimHistory:(Claims*)userClaim;
- (void)findCareWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchUserClaimsWithBody:(NSString*)body forAction:(NSString*)action;
- (void)updateUserProfileWithBody:(NSString*)body forAction:(NSString*)action;
- (void)registerUserWithBody:(NSString*)body forAction:(NSString*)action;
- (void)loadTermsAndConditionsWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchPlanOverviewWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchPricingByLocationWithBody:(NSString*)body forAction:(NSString*)action;
- (void)fetchPricingByZipCodeWithBody:(NSString*)body forAction:(NSString*)action;
- (void)getSupportedVersion;
- (void)cancelOp;
@end
