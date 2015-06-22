//
//  RenewRefillViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 8/29/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "RenewRefillViewController.h"
#import "XMLReader.h"
#import "DDXML.h"
#import "Claims.h"
#import "Drugs.h"
#import "DrugSavingsViewController.h"

@interface RenewRefillViewController ()

@end

@implementation RenewRefillViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Refill";
    // Do any additional setup after loading the view.
    refillAlertImageView.hidden = YES;
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    
    Claims *claim = (Claims *)self.drugInfo;
    
    float timeInterval = [claim.fillDate timeIntervalSinceNow];
    int daysSupply = [claim.daysSupply intValue];
    
    if (timeInterval > 0) {
        daysSupply = 0;
    }
    else {
        int drugDays = roundf(timeInterval/DAY_IN_SECONDS);
        daysSupply = daysSupply + drugDays;
    }
    daysSupply = MAX(0, daysSupply);
    
    
    daysLeftLabel.text =  (daysSupply == 1 ) ? @"Day Left" : @"Days Left";
    daysCountLable.text = [NSString stringWithFormat:@"%d", daysSupply];
    drugNameLabel.text = claim.drug.proddescabbrev;
    navTitleLabel.text = drugNameLabel.text;
    if (daysSupply == 0) {
        refillAlertImageView.hidden = NO;
        
    }
    
    if (daysSupply >0 ) {
        refillStatusBgLabel.backgroundColor = GREEN_COLOR;
        
        if (daysSupply <= 5) {
            refillStatusBgLabel.backgroundColor = ORANGE_COLOR;
            
        }
    }
    fillDateLabel.text = [EHHelpers stringFromDate:[[NSDate date] dateByAddingTimeInterval:(daysSupply * DAY_IN_SECONDS)] format:@"MM/dd/YYYY"];
    
    drugSavingsLabel.text = [NSString stringWithFormat:@"$%0.2f for a %d days Supply", claim.memberPaid.floatValue, claim.daysSupply.intValue];
    savingsLabel.text = [self getSavingsForDrug:claim];
    rxIdLabel.text = [NSString stringWithFormat:@"Rx ID: %@", claim.rxNumber];
    
    [self getPharmacyInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

#pragma mark
#pragma mark PharmacyInfo

// API call for loading medicine data for user
- (void)getPharmacyInfo {
    
    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser) {
        Claims *claim = (Claims *)self.drugInfo;
        
        if (claim.pharmacy != nil) {
            [self loadPharmacyDetailsFromDB:claim.pharmacy];
        }
        else{

            if ([EHHelpers isNetworkAvailable]) {
                
                NSString *soapAction = [NSString stringWithFormat:@"%@/GetPharmacyByNABP", API_ACTION_ROOT];
                NSString *soapBodyXML = [NSString stringWithFormat:EHGetPharmacyByNABP, currentuser.email, currentuser.guid, claim.pharmacyId, AppID];
                
                NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML, API_ROOT, currentuser.email, currentuser.password, soapBodyXML];
                [InfoAlert info:@"Loading"];
                [self.networkOperation fetchPurchasedPharmacyInfoWithBody:soapBody forAction:soapAction];
            }
            else{
                [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
            }
        }
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
        [self logOutUser];
        
    }
}

- (void)successfullyFetchedPurchasedPharmacyData:(NSArray *)data {
    
    [InfoAlert dismiss];
    if ([data count] > 0) {
        [self cachePharmacyDetails:data[0]];
    }

    
}
- (void)error:(NSError *)operationError {
    
    [InfoAlert dismiss];
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
        if ([errorMessage isEqualToString:@"Invalid GUID. Please log in again"]) {
            [self logOutUser];
        }
    }

}

#pragma mark
#pragma mark LogOut

- (void)logOutUser {
    
    [APP_DELEGATE setCurrentUser:nil];
    [APP_DELEGATE stopSessionTimer];
    
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC.leftMenu performSegueWithIdentifier:@"showMedicineCabinetSegue" sender:nil];
}

#pragma mark
#pragma mark Pharmacy Load, Cache and Update
// load pharmacy data from local cache
- (void)loadPharmacyDetailsFromDB:(Pharmacy*)pharmacyDB {
    
    self.pharmacyDetails = [NSMutableDictionary dictionary];
    
    self.pharmacyDetails[@"name"] = pharmacyDB.name;
    self.pharmacyDetails[@"nabp"] =  pharmacyDB.nabp;
    self.pharmacyDetails[@"pAddress"] = pharmacyDB.pAddress;
    self.pharmacyDetails[@"sAddress"] = pharmacyDB.sAddress;
    self.pharmacyDetails[@"city"] = pharmacyDB.city;
    self.pharmacyDetails[@"state"] = pharmacyDB.state;
    self.pharmacyDetails[@"zip"] = pharmacyDB.zip;
    self.pharmacyDetails[@"phone"] = pharmacyDB.phone;
    self.pharmacyDetails[@"lat"] = pharmacyDB.lat;
    self.pharmacyDetails[@"lon"] = pharmacyDB.lon;
    self.pharmacyDetails[@"distance"] = pharmacyDB.distance;
    
    self.pharmacyDetails[@"dispType"] = pharmacyDB.dispType;
    self.pharmacyDetails[@"dispClass"] = pharmacyDB.dispClass;
    self.pharmacyDetails[@"icon"] = pharmacyDB.icon;
    self.pharmacyDetails[@"monHrs"] = pharmacyDB.monHrs;
    self.pharmacyDetails[@"tueHrs"] = pharmacyDB.tueHrs;
    self.pharmacyDetails[@"wedHrs"] = pharmacyDB.wedHrs;
    self.pharmacyDetails[@"thuHrs"] = pharmacyDB.thuHrs;
    self.pharmacyDetails[@"friHrs"] = pharmacyDB.friHrs;
    self.pharmacyDetails[@"satHrs"] = pharmacyDB.satHrs;
    self.pharmacyDetails[@"sunHrs"] = pharmacyDB.sunHrs;
    self.pharmacyDetails[@"retail"] = pharmacyDB.retail;
    self.pharmacyDetails[@"vaccNetwork"] = pharmacyDB.vaccNetwork;
    
    self.pharmacyDetails[@"AFFILIATIONCODE"] = pharmacyDB.affiliationCode;
    
    pharmacyNameLabel.text = [self isMailOrderPharmacy] == YES ? @"Orchard Pharmacy" : self.pharmacyDetails[@"name"];
    pharmacyAddrLabel.text = [self isMailOrderPharmacy] == YES ? [NSString stringWithFormat:@"Mail Order\n\nPhone: %@",[EHHelpers formatToPhoneNumber:self.pharmacyDetails[@"phone"]]]: [self pharmaAddressDetails:self.pharmacyDetails forKeys:@[@"pAddress",@"sAddress",@"city",@"state",@"zip"]];
    
}

// Cache pharmacy data to db
- (void)cachePharmacyDetails:(DDXMLElement*)element {
    
    self.pharmacyDetails = [NSMutableDictionary dictionary];
    
    self.pharmacyDetails[@"name"] = [EHHelpers stringByRemovingSpecialCharacters:[EHHelpers xmlElementValueForKey:@"PHARMACYNAME" forXmlElement:element]];
    self.pharmacyDetails[@"nabp"] =  [EHHelpers xmlElementValueForKey:@"NABP" forXmlElement:element];
    self.pharmacyDetails[@"pAddress"] = [EHHelpers xmlElementValueForKey:@"PHARMADDR1" forXmlElement:element];
    self.pharmacyDetails[@"sAddress"] = [EHHelpers xmlElementValueForKey:@"PHARMADDR2" forXmlElement:element];
    self.pharmacyDetails[@"city"] = [EHHelpers xmlElementValueForKey:@"PHARMCITY" forXmlElement:element];
    self.pharmacyDetails[@"state"] = [EHHelpers xmlElementValueForKey:@"PHARMSTATE" forXmlElement:element];
    self.pharmacyDetails[@"zip"] = [EHHelpers xmlElementValueForKey:@"PHARMZIP" forXmlElement:element];
    self.pharmacyDetails[@"phone"] = [EHHelpers xmlElementValueForKey:@"PHONE" forXmlElement:element];
    self.pharmacyDetails[@"lat"] = [EHHelpers xmlElementValueForKey:@"LATITUDE" forXmlElement:element];
    self.pharmacyDetails[@"lon"] = [EHHelpers xmlElementValueForKey:@"LONGITUDE" forXmlElement:element];
    self.pharmacyDetails[@"distance"] = [EHHelpers xmlElementValueForKey:@"DISTANCE" forXmlElement:element];
    
    self.pharmacyDetails[@"dispType"] = [EHHelpers xmlElementValueForKey:@"DISPTYPE" forXmlElement:element];
    self.pharmacyDetails[@"dispClass"] = [EHHelpers xmlElementValueForKey:@"DISPCLASS" forXmlElement:element];
    self.pharmacyDetails[@"icon"] = [EHHelpers xmlElementValueForKey:@"ICON" forXmlElement:element];
    self.pharmacyDetails[@"monHrs"] = [EHHelpers xmlElementValueForKey:@"MONHOURS" forXmlElement:element];
    self.pharmacyDetails[@"tueHrs"] = [EHHelpers xmlElementValueForKey:@"TUEHOURS" forXmlElement:element];
    self.pharmacyDetails[@"wedHrs"] = [EHHelpers xmlElementValueForKey:@"WEDHOURS" forXmlElement:element];
    self.pharmacyDetails[@"thuHrs"] = [EHHelpers xmlElementValueForKey:@"THUHOURS" forXmlElement:element];
    self.pharmacyDetails[@"friHrs"] = [EHHelpers xmlElementValueForKey:@"FRIHOURS" forXmlElement:element];
    self.pharmacyDetails[@"satHrs"] = [EHHelpers xmlElementValueForKey:@"SATHOURS" forXmlElement:element];
    self.pharmacyDetails[@"sunHrs"] = [EHHelpers xmlElementValueForKey:@"SUNHOURS" forXmlElement:element];
    self.pharmacyDetails[@"retail"] = [EHHelpers xmlElementValueForKey:@"RETAIL90" forXmlElement:element];
    self.pharmacyDetails[@"vaccNetwork"] = [EHHelpers xmlElementValueForKey:@"VACCINENETWORK" forXmlElement:element];
    
    self.pharmacyDetails[@"AFFILIATIONCODE"] = [EHHelpers xmlElementValueForKey:@"AFFILIATIONCODE" forXmlElement:element];
    
    pharmacyNameLabel.text = [self isMailOrderPharmacy] == YES ? @"Orchard Pharmacy" : self.pharmacyDetails[@"name"];
    pharmacyAddrLabel.text = [self isMailOrderPharmacy] == YES ? [NSString stringWithFormat:@"Mail Order\n\nPhone: %@",[EHHelpers formatToPhoneNumber:self.pharmacyDetails[@"phone"]]]: [self pharmaAddressDetails:self.pharmacyDetails forKeys:@[@"pAddress",@"sAddress",@"city",@"state",@"zip"]];
    [self updatePharmacyDB];
    
}

// Update DB with pharmacy info
- (void)updatePharmacyDB {
    
    NSManagedObjectContext *const ctx = [APP_DELEGATE managedObjectContext];
    
    Claims *claim = (Claims *)self.drugInfo;
    Pharmacy *pharmacyObj = nil;
    
    NSFetchRequest *getPharmacyItem = [NSFetchRequest
                                       fetchRequestWithEntityName:[Pharmacy entityName]];
    
    getPharmacyItem.predicate = [NSPredicate
                                 predicateWithFormat:@"nabp == %@", claim.prescriberId];
    __block NSArray *matchingItems = [ctx executeFetchRequest:getPharmacyItem
                                                        error:nil];
    if (matchingItems.count > 0) {
        pharmacyObj = [matchingItems objectAtIndex:0];
    }
    else
    {
        pharmacyObj = [NSEntityDescription insertNewObjectForEntityForName:[Pharmacy entityName] inManagedObjectContext:ctx];
    }
    pharmacyObj.icon            = self.pharmacyDetails[@"icon"];
    pharmacyObj.name            =self.pharmacyDetails[@"name"];
    pharmacyObj.nabp            =self.pharmacyDetails[@"nabp"];
    pharmacyObj.pAddress        =self.pharmacyDetails[@"pAddress"];
    pharmacyObj.sAddress        =self.pharmacyDetails[@"sAddress"];
    pharmacyObj.city            =self.pharmacyDetails[@"city"];
    pharmacyObj.state           =self.pharmacyDetails[@"state"];
    pharmacyObj.zip             =self.pharmacyDetails[@"zip"];
    pharmacyObj.phone           =self.pharmacyDetails[@"phone"];
    pharmacyObj.lat             =self.pharmacyDetails[@"lat"];
    pharmacyObj.lon             =self.pharmacyDetails[@"lon"];
    pharmacyObj.distance        =self.pharmacyDetails[@"distance"];
    pharmacyObj.dispType        =self.pharmacyDetails[@"dispType"];
    pharmacyObj.dispClass       =self.pharmacyDetails[@"dispClass"];
    pharmacyObj.monHrs          =self.pharmacyDetails[@"monHrs"];
    pharmacyObj.tueHrs          =self.pharmacyDetails[@"tueHrs"];
    pharmacyObj.wedHrs          =self.pharmacyDetails[@"wedHrs"];
    pharmacyObj.thuHrs          =self.pharmacyDetails[@"thuHrs"];
    pharmacyObj.friHrs          =self.pharmacyDetails[@"friHrs"];
    pharmacyObj.satHrs          =self.pharmacyDetails[@"satHrs"];
    pharmacyObj.sunHrs          =self.pharmacyDetails[@"sunHrs"];
    pharmacyObj.retail          =self.pharmacyDetails[@"retail"];
    pharmacyObj.vaccNetwork     =self.pharmacyDetails[@"vaccNetwork"];
    pharmacyObj.affiliationCode =self.pharmacyDetails[@"AFFILIATIONCODE"];
    
    claim.pharmacy = pharmacyObj;
    [ctx save:nil];
    
    
}

// Check whether the drug is purchased from Orchard Pharmacy

- (BOOL)isMailOrderPharmacy {
    
    if ([self.pharmacyDetails[@"nabp"] intValue] == [MailOrderPharmacyId intValue]) {
        return YES;
    }
    return NO;
}

// Prepare address for the pharmacy separated by comma
- (NSString*)pharmaAddressDetails:(NSDictionary*)pharmacy forKeys:(NSArray*)keyValues {
    
    NSMutableArray *addressarray = [NSMutableArray array];
    
    for (NSString *phamaKeys  in keyValues) {
        if ([pharmacy[phamaKeys] length] > 0) {
            [addressarray addObject:pharmacy[phamaKeys]];
        }
    }
    return [addressarray count] > 0 ? [addressarray componentsJoinedByString:@", "] : [NSString string];
}

#pragma mark
#pragma mark MONY Savings

// Savings type for drug
- (NSString *)getSavingsForDrug:(Claims *)claim {
    
    NSString *mony = claim.drug.multisource;
    if ([mony isEqualToString:@"Y"]) {
        return @"LIKELY SAVINGS: LOW";
    }
    else if ([mony isEqualToString:@"O"]) {
        return @"LIKELY SAVINGS: HIGH";
    }
    else {
        
        User *currentuser = [APP_DELEGATE currentUser];
        
        if (currentuser) {
            
            NSString *soapAction = [NSString stringWithFormat:@"%@/GetGenericEquivalentByBrandNDC", API_ACTION_ROOT];
            NSString *soapBodyXML = [NSString stringWithFormat:EHDrugByBrandNDC, currentuser.email, currentuser.guid, claim.drug.ndc, AppID];
            
            NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2,  soapBodyXML];
            [self.networkOperation fetchMultisourceLikelySavingsDataWithBody:soapBody forAction:soapAction withClaimHistory:claim];
        }
    }
    return @"Fetching Savings...";
}

#pragma mark Multisource Response Data

- (void)successFullyFetchedMultiSourceSavingsData:(NSArray *)data withClaimHistory:(Claims *)claim{

    if ([data count] > 0) {
        DDXMLElement *drugElement = data[0];
        NSString *ndc = [EHHelpers xmlElementValueForKey:@"INGREDIENT" forXmlElement:drugElement];
        if ([ndc boolValue] > 0) {
            claim.drug.multisource = @"O";
            savingsLabel.text = @"LIKELY SAVINGS: HIGH";

        }
        else {
            claim.drug.multisource = @"Y";
            savingsLabel.text = @"LIKELY SAVINGS: LOW";

        }
        [[APP_DELEGATE managedObjectContext] save:nil];

    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Public Methods

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//  Call Pharmacy

- (IBAction)callPharmacy {
    
    
    if ([self isMailOrderPharmacy] == YES) {
        [EHHelpers registerGAWithCategory:@"Mail Order Pharmacy" forAction:@"Call Orchard Pharmacy"];
    }
    else{
        [EHHelpers registerGAWithCategory:@"Refill - Call Pharmacy" forAction:self.pharmacyDetails[@"name"]];

    }
    NSString *phoneStr = [NSString stringWithFormat:@"telprompt:%@", self.pharmacyDetails[@"phone"]];
    NSURL *url  = [NSURL URLWithString:phoneStr];
    [[UIApplication sharedApplication] openURL:url];
    
}

// Show drug likely savings
- (IBAction)showSavings:(id)sender {
    
    DrugSavingsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"DrugSavingsViewController"];
    vc.drugInfo= self.drugInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

// Show Pharmacy Info with map details

- (IBAction)showPharmacyDetails:(id)sender {

    if ([self isMailOrderPharmacy] == YES) {
        OrchardPharmacyViewController *orchardView = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"OrchardPharmacyViewController"];
        orchardView.showSavings = NO;
        [self.navigationController pushViewController:orchardView animated:YES];
        
    }
    else {
        
        if (self.pharmacyDetails != nil) {
            
            PharmacyDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"PharmacyDetailViewController"];
            vc.pharmacyDetail= [NSDictionary dictionaryWithDictionary:self.pharmacyDetails];
            vc.showDrugInfo = NO;
            vc.isFromRefill = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            [EHHelpers showAlertWithTitle:@"" message:@"Pharmacy info not available" delegate:nil];
        }
    }
}
@end
