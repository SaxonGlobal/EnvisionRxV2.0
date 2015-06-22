//
//  Constants.h
//  Engage Health
//
//  Created by Nithin on 4/17/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#ifdef DEBUG
#define NSLOG NSLog
#else
#define NSLOG if(false)NSLog
#endif

#import "AppDelegate.h"

#define kLoginExpiration @"20"
#define GA_TRACKING @"UA-57424943-1"
#define kBugSnagAPIKey @"59f47e408d6df15149ef0193444e053e"

#define ORANGE_COLOR [UIColor colorWithRed:0.972549 green:0.592157 blue:0.239216 alpha:1.0] // 248, 151, 61
#define GREEN_COLOR [UIColor colorWithRed:0.388235 green:0.709804 blue:0.419608 alpha:1.0] //99, 181, 107
#define BLUE_COLOR [UIColor colorWithRed:0.200000 green:0.376471 blue:0.494118 alpha:1.0] //51, 96, 126

#define kTestFlightToken @"740ad5ec-9335-4bf1-ab4b-558c799c7005"

#define API_ROOT @"ws.pbmexpress.com/"
#define API_ACTION_ROOT @"http://ws.PBMExpress.com"
#define API_HOST_PATH @"envisionrx.asmx"

#define kNotificationMessage @"It's time to take your %@"
#define FaqUpdatedDate @"FaqUpdatedDate"
#define MedicineCabinetUpdatedDate @"MedicineCabinetUpdatedDate"
#define kLoginEmail @"testenvisionapi@envisionrx.com"
#define kLoginPassword @"testaccount"
#define sqliteDateFormat @"yyyy-MM-dd"
#define kDefaultDateFormat @"yyyy/MM/dd HH:mm:ss Z"
#define kUserAlerts @"UserAlerts"
#define XML_CUSTOM_XPATH @"//*[local-name() = '%@']"

#define HOUR_IN_SECONDS (60*60)
#define DAY_IN_SECONDS (HOUR_IN_SECONDS*24)
#define MONTH_IN_SECONDS (DAY_IN_SECONDS*30)
#define YEAR_IN_SECONDS (DAY_IN_SECONDS*365)

#define Saving_Red [UIColor colorWithRed:171.0/255.0 green:16.0/255.0 blue:21.0/255.0 alpha:1.0]
#define Saving_White [UIColor whiteColor]
#define Security_Question_File @"SecurityQuestion.plist"
#define Terms_Condition @"Terms.plist"
#define BenefitsDataFile @"Benefit_DataFile"
#define kPlanUpdateDate @"kPlanUpdateDate"

#define MailOrderPharmacyId @"3677361"
#define MailOrderPharmacyOrderQuantity 90
#define MailOrderPharmacySupplyDays 90

#define DefaultPharmacyRadius 10
#define DefaultClaimsInterval 6
#define DefaultNumberOfPharmacy 10
#define ITUNES_URL @"https://itunes.apple.com/us/app/id944852932?mt=8"

#define AppID @"2Fw3dsQS"

#define SOAP_BODY_XML @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>%@</soap:Body></soap:Envelope>"

#define AUTH_SOAP_BODY_XML @"<?xml version=\"1.0\" encoding=\"utf-8\"?> <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><UserCredentials xmlns=\"http://%@\"><UserID>%@</UserID><Password>%@</Password></UserCredentials></soap:Header><soap:Body>%@</soap:Body></soap:Envelope>"

#define AUTH_SOAP_BODY_XML_2 @"<?xml version=\"1.0\" encoding=\"utf-8\"?> <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>%@</soap:Body></soap:Envelope>"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define HEIGHT_IPHONE_5 568
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == HEIGHT_IPHONE_5 )

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]

#define APPLICATION_FONT_NORMAL @"Calibri"
#define APPLICATION_FONT_BOLD @"Calibri-Bold"
//to convert hex to RGB
#define UIColorFromHex(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]
#define searchBarlightBlue UIColorFromHex(0xcbf0ff)
#define searchBarBorderColor UIColorFromHex(0x26ade4)
#define lightBlue UIColorFromHex(0x26ade4)
#define white UIColorFromHex(0xffffff)
#define darkGray UIColorFromHex(0x3e3e3e)
#define peach UIColorFromHex(0xff7c6b)
#define beige UIColorFromHex(0xf8f8f2)
#define darkBlue UIColorFromHex(0x000099)
#define leafgreen UIColorFromHex(0x61B329)

#define PlaceHolderColor [UIColor colorWithRed:122.0/255.0 green:131.0/255.0 blue:158.0/255.0 alpha:1.0]
#define MinimumZipCode 5

#define kNotificationAlert @"AlertNotification"
#define DaysOfTheWeek @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"]

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

// *****
#define EHClaims @"<ClaimsHistory xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><PersonCode>%d</PersonCode><StartDate>%@</StartDate><EndDate>%@</EndDate><AppID>%@</AppID></ClaimsHistory>"
//****

#define EHLogin @"<UserLogin xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><Password>%@</Password><AppID>%@</AppID></UserLogin>"

//****

#define EHGetPharmacies @"<GetPharmacies xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><PharmacyName></PharmacyName><ZipCode>%@</ZipCode><City></City><State></State><Distance>%@</Distance><MaxPharmacies>%d</MaxPharmacies><AppID>%@</AppID></GetPharmacies>"

//****

#define EHGetPharmaciesByLatLon @"<GetPharmaciesByLatLong xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID> <Latitude>%@</Latitude><Longitude>%@</Longitude><Distance>%@</Distance><MaxPharmacies>%d</MaxPharmacies><AppID>%@</AppID></GetPharmaciesByLatLong>"
//*****
#define EHGetPharmacyByNABP @" <GetPharmacyByNABP xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><NABP>%@</NABP><AppID>%@</AppID></GetPharmacyByNABP>"

//****

#define EHFAQ @"<GetFAQ xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><AppID>%@</AppID></GetFAQ>"

//**
//****

#define EHPlanOverView @"<GetPlanOverview xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><AppID>%@</AppID></GetPlanOverview>"

#define EHPasswordRetrieval @"<PasswordRetrieval xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><AppID>%@</AppID></PasswordRetrieval>"
//**

#define EHDrugPricingByLatLon @"<GetDrugPricingByLatLong xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><NDC>%@</NDC><Qty>%d</Qty><Days>%d</Days><Latitude>%@</Latitude><Longitude>%@</Longitude><Distance>%@</Distance><MaxPharmacies>%d</MaxPharmacies><AppID>%@</AppID></GetDrugPricingByLatLong>"

#define EHDrugPricingByZipCode @"<GetDrugPricingByZipcode xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><NDC>%@</NDC><Qty>%d</Qty><Days>%d</Days><Distance>%@</Distance><ZipCode>%@</ZipCode><MaxPharmacies>%d</MaxPharmacies><AppID>%@</AppID></GetDrugPricingByZipcode>"


#define EHSavingsDrugByGPI @"<GetDrugByGPI xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><GPI>%@</GPI><AppID>%@</AppID></GetDrugByGPI>"

#define EHDrugPricingByNABP @"<GetDrugPricingByNABP xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><NDC>%@</NDC><Qty>%d</Qty><Days>%d</Days><NABP>%@</NABP><AppID>%@</AppID></GetDrugPricingByNABP>"


#define EHSecurityQuestion @"<GetSecurityQuestions xmlns=\"http://ws.PBMExpress.com/\" />"

#define EHTermsAndConditions @"<GetTermsAndConditions xmlns=\"http://ws.PBMExpress.com/\" />"

#define EHUserRegistration @"<UserRegistration xmlns=\"http://ws.PBMExpress.com/\"><FirstName>%@</FirstName><LastName>%@</LastName><DOB>%@</DOB><Gender>%@</Gender><MemberID>%@</MemberID><RelationID>%d</RelationID><Email>%@</Email><Password>%@</Password><QuestionID>%d</QuestionID><Answer>%@</Answer><HouseholdFlag>%d</HouseholdFlag><AppID>%@</AppID></UserRegistration>"

#define EHUpdateMemberAccount @"<UpdateMemberAccount xmlns=\"http://ws.PBMExpress.com/\"><member><MemberID>%@</MemberID><PersonCode>%d</PersonCode><FirstName>%@</FirstName><LastName>%@</LastName><DOB>%@</DOB><Gender>%@</Gender><RelationID>%d</RelationID><GroupID>%@</GroupID><Carrier>%@</Carrier><ZipCode>%@</ZipCode><AccountID>%d</AccountID><GUID>%@</GUID><Password>%@</Password><Email>%@</Email><Phone>%@</Phone><Question>%@</Question><QuestionID>%d</QuestionID><Answer>%@</Answer><Pharmacy>%@</Pharmacy><PharmacyName>%@</PharmacyName><ChainCode>%@</ChainCode><BIN>%@</BIN><PCN>%@</PCN><MemberHelp>%@</MemberHelp><PharmacyHelp>%@</PharmacyHelp><LogoURL>%@</LogoURL><MailOrderID>%d</MailOrderID><MailOrderNABP>%d</MailOrderNABP><HouseholdFlag>%d</HouseholdFlag><Enabled>%d</Enabled><SSO>%d</SSO></member><AppID>%@</AppID></UpdateMemberAccount>"

#define RelationList @[@{ @"text":@"I am a member",@"id":@"1"},@{@"text":@"I am a spouse",@"id":@"2"},@{@"text":@"I am a domestic partner",@"id":@"3"},@{@"text":@"I am an adult dependent",@"id":@"4"}]

#define EHDrugByBrandNDC @"<GetGenericEquivalentByBrandNDC xmlns=\"http://ws.PBMExpress.com/\"><Email>%@</Email><GUID>%@</GUID><NDC>%@</NDC><AppID>%@</AppID></GetGenericEquivalentByBrandNDC>"

#define EHSupportedVersion @"<GetSupportedVersion xmlns=\"http://ws.PBMExpress.com/\"><PhoneType>0</PhoneType><AppID>%@</AppID></GetSupportedVersion>"



