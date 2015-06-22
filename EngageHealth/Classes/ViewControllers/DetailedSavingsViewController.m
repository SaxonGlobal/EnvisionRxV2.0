//
//  DetailedSavingsViewController.m
//  EngageHealth
//
//  Created by Nassif on 09/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "DetailedSavingsViewController.h"
#import "EHOperation.h"

@interface DetailedSavingsViewController ()<EHOperationProtocol>

@property (nonatomic ,strong) EHOperation *networkOperation;
@property (nonatomic ,strong) NSArray *dayKeys;

@end

@implementation DetailedSavingsViewController

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
    
    self.dayKeys = [NSArray arrayWithObjects:@"sunHrs", @"monHrs", @"tueHrs", @"wedHrs", @"thuHrs", @"friHrs", @"satHrs",nil];

    self.screenName = @"Likely Savings Screen 2";
    noPharmacyView.hidden = YES;
    self.sortType = 1;
    searchButton.hidden = YES;
    [self initialiseHideKeyboardButton];
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    
    titleLabel.text = self.drugInfo.name;
    [[EHLocationService sharedInstance].locationManager startUpdatingLocation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deactivateKeyBoard) name:@"OpenLeftMenuNotification" object:nil];
    
    [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
    
    self.pharmacy = [NSMutableArray array];
    [self sortSAvingsListByType:self.sortType];
    [savingsTableView reloadData];
    [self initialiseLoadingView];
    [self addNotificationListeneForKeyBoard];
    if ([EHHelpers isNetworkAvailable]) {
        [self loadMailOrderPharmacySavings];
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.networkOperation cancelOp];
}
- (void)deactivateKeyBoard {
    [searchTextField resignFirstResponder];
}

#pragma mark
#pragma mark KeyBoardNotificationHandler
// Add listener for keyboard notifications
- (void)addNotificationListeneForKeyBoard {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
}

// Listener delegate >> Custom the screen while the keyboard is shown
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    self.keyBoardSearchButtonContraint.constant = kbRect.size.height ;
    [self.view bringSubviewToFront:keyBoardSearchView];
    [self.view updateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
}

// Keyboard notifications actions : On hidden
- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    
    self.keyBoardSearchButtonContraint.constant = - 44;
    [self.view updateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    
}

#pragma mark
#pragma mark CustomLoadingView
// Initialise the custom loading view
- (void)initialiseLoadingView {
    
    self.customLoadingView = [[LoadingView alloc] init];
    self.customLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
}

// Show loading screen
- (void)showLoadingView {
    
    if (self.customLoadingView == nil) {
        [self initialiseLoadingView];
    }
    [self.view addSubview:self.customLoadingView];
    UIView *loadingView = self.customLoadingView;
    NSDictionary *views = NSDictionaryOfVariableBindings(loadingView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[loadingView]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[loadingView]|" options:0  metrics:nil views:views]];
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    [self.customLoadingView startAnimations];
    
}

// Back Action
- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark OrchardPharmacy Pricing
// Find the savings details of a drug with Mail Order Pharmacy
- (void)loadMailOrderPharmacySavings {
    
    self.isSearching = YES;
    NSString *pharmacyId = MailOrderPharmacyId;
    NSString *ndc = self.drugInfo.ndc;
    
    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser ) {
        float daysSupply = 90/self.claimsInfo.daysSupply.intValue;
        int quantity = roundf(self.claimsInfo.quantity.intValue * daysSupply);
        
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetDrugPricingByNABP", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHDrugPricingByNABP, currentuser.email,currentuser.guid ,ndc ,quantity,90,pharmacyId,AppID] ;
        
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
        
        [self showLoadingView];
        [self.networkOperation fetchDrugPricingByNABPWithBody:soapBody forAction:soapAction withNDC:@""];
        ;
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
        [self logOutUser];
        
    }
}

- (void)successFUllyReceivedPricingData:(NSArray *)pricingData withNDC:(NSString *)ndc {
    
    self.isSearching = NO;
    [self addOrchardPharmacyDetails:pricingData];
    
}

- (void)error:(NSError *)operationError {
    
    self.isSearching = NO;
    [self.customLoadingView clearAllAnimations];
    [self.customLoadingView removeFromSuperview];
    self.customLoadingView = nil;
    
    if ([[operationError localizedDescription] isEqualToString:@"The Internet connection appears to be offline."]) {
        [EHHelpers showAlertWithTitle:@"" message:@"Unable to connect to the network." delegate:nil];
    }
    else{
        NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
        if ([errorMessage length] > 0) {
            [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
            if ([errorMessage isEqualToString:@"Invalid GUID. Please log in again"]) {
                [self logOutUser];
            }
        }
        
    }
}

- (BOOL)isPharmacyOpen:(NSString *)opHours {
    
    NSArray *timeSplits = [[opHours stringByReplacingOccurrencesOfString:@"." withString:@""] componentsSeparatedByString:@"-"];
    
    if ([timeSplits count] > 1) {
        NSString *startTime = timeSplits[0];
        NSString *endTime = timeSplits[1];
        NSString *currentDate = [EHHelpers stringFromDate:[NSDate date] format:@"yyyy/MM/dd"];
        
        NSDate *startDate = [EHHelpers dateFromString:[NSString stringWithFormat:@"%@ %@", currentDate, startTime]];
        NSDate *endDate = [EHHelpers dateFromString:[NSString stringWithFormat:@"%@ %@", currentDate, endTime]];
        NSDate *now = [NSDate date];
        
        return [EHHelpers date:now isBetweenDate:startDate andDate:endDate];
    }
    return NO;
}

#pragma mark
#pragma mark LogOut

- (void)logOutUser {
    
    [APP_DELEGATE setCurrentUser:nil];
    [APP_DELEGATE stopSessionTimer];
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC.leftMenu performSegueWithIdentifier:@"showMedicineCabinetSegue" sender:nil];
    
}


// Add Mail Orchard Pharmacy details to the list
- (void)addOrchardPharmacyDetails:(NSArray*)orchardPharmacy {
    
    [self  addSavingsDetails:orchardPharmacy withType:@"0"];
    [self findDetailedSavings];
    
}

/*Pricing Algorithm
 
 DaysSuppy = if searching for orchardpharmacy it is 90 or claim.daysupply
 ClaimsDrugPerYearCost = (claim.MemberPay/claim.daysupply)*365;
 AlternativeDrugCost = (alternativeDrug.Copay/claim.daysupply)*365;
 Savings = ClaimsDrugPerYearCost - AlternativeDrugCost;
 */

#pragma mark
#pragma mark Pricing Algorithm
// Prepare the saving details
- (void)addSavingsDetails:(NSArray*)savings withType:(NSString*)type{
    
    
    int daysSupply =  self.claimsInfo.daysSupply.intValue;
    
    float drugPrice =  [self.claimsInfo.memberPaid floatValue];
    
    float drugPerYearPrice = (drugPrice /daysSupply ) *365;
    
    NSArray *filteredArray = [self.pharmacy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderType.intValue == %d",1]];
    if ([filteredArray count] > 0) {
        [self.pharmacy removeObjectsInArray:filteredArray];
    }
    
    if ([savings count] > 0) {
        
        for (DDXMLElement *Drug in savings) {
            
            
            NSArray *pharmacyList = [Drug elementsForName:@"RxClaims"];
            
            NSArray *priceDetails = [NSArray array];
            NSArray *drugdetails = [NSArray array];
            NSArray *pharmacyDetails =  [NSArray array];
            
            if ([pharmacyList count] > 0 ) {
                
                for (DDXMLElement *pharma in pharmacyList) {
                    
                    priceDetails =[pharma elementsForName:@"RxClaim"];
                    NSString *pricingErrorMessage = @"";
                    if ([priceDetails count] > 0) {
                        
                        
                        for (DDXMLElement *nearestPharmacy in priceDetails) {
                            int status = 0;
                            
                            drugdetails = [nearestPharmacy elementsForName:@"DrugCost"];
                            NSMutableDictionary *drugCostDetail = [NSMutableDictionary dictionary];
                            if ([drugdetails count]> 0 ) {
                                DDXMLElement *cost = drugdetails[0];
                                drugCostDetail[@"Copay"] = [EHHelpers xmlElementValueForKey:@"Copay" forXmlElement:cost];
                                drugCostDetail[@"PlanPay"] = [EHHelpers xmlElementValueForKey:@"PlanPay" forXmlElement:cost];
                               
                                if([drugCostDetail[@"Copay"] length] > 0){
                                    status = 1;
                                }
                            }
                            
                            if ([drugCostDetail count] == 0 || [drugCostDetail[@"Copay"] length] == 0){
                                pricingErrorMessage = @"THERE IS NO PRICING INFORMATION FOR THIS DRUG AT THIS TIME";
                            }
                            
                            
                            if ([priceDetails count] > 0) {
                                NSArray *message = [priceDetails [0] elementsForName:@"Response"];
                                if ([message count] > 0) {
                                    NSArray *messageContent = [message [0] elementsForName:@"Status"];
                                    if ([messageContent count] > 0) {
                                        if ([[messageContent[0] stringValue] isEqualToString:@"R"]) {
                                            pricingErrorMessage = [[message [0] elementsForName:@"Message"][0] stringValue ];
                                            status = 0;
                                        }
                                    }
                                    
                                }
                            }
                            
                            pharmacyDetails = [nearestPharmacy elementsForName:@"Pharmacy"];
                            NSMutableDictionary *pharmaDetail = [NSMutableDictionary dictionary];
                            
                            if ([pharmacyDetails count] > 0) {
                                DDXMLElement *pharmacyXMl = pharmacyDetails[0];
                                
                                pharmaDetail[@"name"] = [EHHelpers stringByRemovingSpecialCharacters:[EHHelpers xmlElementValueForKey:@"PHARMACYNAME" forXmlElement:pharmacyXMl]];
                                pharmaDetail[@"nabp"] =  [EHHelpers xmlElementValueForKey:@"NABP" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"pAddress"] = [EHHelpers xmlElementValueForKey:@"PHARMADDR1" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"sAddress"] = [EHHelpers xmlElementValueForKey:@"PHARMADDR2" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"city"] = [EHHelpers xmlElementValueForKey:@"PHARMCITY" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"state"] = [EHHelpers xmlElementValueForKey:@"PHARMSTATE" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"zip"] = [EHHelpers stringByRemovingSpecialCharacters:[EHHelpers xmlElementValueForKey:@"PHARMZIP" forXmlElement:pharmacyXMl]];
                                pharmaDetail[@"phone"] = [EHHelpers xmlElementValueForKey:@"PHONE" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"lat"] = [EHHelpers xmlElementValueForKey:@"LATITUDE" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"lon"] = [EHHelpers xmlElementValueForKey:@"LONGITUDE" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"distance"] = [EHHelpers xmlElementValueForKey:@"DISTANCE" forXmlElement:pharmacyXMl];
                                
                                pharmaDetail[@"dispType"] = [EHHelpers xmlElementValueForKey:@"DISPTYPE" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"dispClass"] = [EHHelpers xmlElementValueForKey:@"DISPCLASS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"icon"] = [EHHelpers xmlElementValueForKey:@"ICON" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"monHrs"] = [EHHelpers xmlElementValueForKey:@"MONHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"tueHrs"] = [EHHelpers xmlElementValueForKey:@"TUEHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"wedHrs"] = [EHHelpers xmlElementValueForKey:@"WEDHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"thuHrs"] = [EHHelpers xmlElementValueForKey:@"THUHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"friHrs"] = [EHHelpers xmlElementValueForKey:@"FRIHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"satHrs"] = [EHHelpers xmlElementValueForKey:@"SATHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"sunHrs"] = [EHHelpers xmlElementValueForKey:@"SUNHOURS" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"retail"] = [EHHelpers xmlElementValueForKey:@"RETAIL90" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"vaccNetwork"] = [EHHelpers xmlElementValueForKey:@"VACCINENETWORK" forXmlElement:pharmacyXMl];
                                pharmaDetail[@"Copay"] = drugCostDetail[@"Copay"];
                                pharmaDetail[@"PlanPay"] = drugCostDetail[@"PlanPay"];
                                pharmaDetail[@"PRODDESCABBREV"] = self.drugInfo.name;
                            }
                            float savings = 0;
                            if ([drugCostDetail count] > 0) {
                                daysSupply =  (type.intValue == 0) ? MailOrderPharmacySupplyDays : self.claimsInfo.daysSupply.intValue;
                                savings =    ([drugCostDetail[@"Copay"] floatValue] / daysSupply )*365;
                                pharmaDetail[@"save"] = [NSNumber numberWithFloat:drugPerYearPrice -savings];
                                pharmaDetail[@"errorMessage"] = ([self shouldCalculateSavingsForOrchardType:type] == YES) ? pricingErrorMessage :@"THERE IS NO PRICING INFORMATION FOR THIS DRUG AT THIS TIME";
                                
                            }
                            pharmaDetail[@"hasSavings"] = ([self shouldCalculateSavingsForOrchardType:type] == YES ) ? [drugCostDetail count] > 0 && ([drugCostDetail[@"Copay"] length] !=0 )? @"1" : @"" : @"";
                            pharmaDetail[@"orderType"] = [NSNumber numberWithInt:[type intValue]];
                            pharmaDetail[@"status"] = [NSNumber numberWithInt:status];
                            [self.pharmacy addObject:pharmaDetail];
                            
                        }
                    }
                    
                }
                
            }
            
        }
    }
    [self sortSAvingsListByType:self.sortType];
}

// Check whether the calculation is done for orchard pharmacy
- (BOOL)shouldCalculateSavingsForOrchardType:(NSString*)type {
    
    BOOL shouldCalculate = YES;
    
    if (type.intValue == 0 ){
        if (self.claimsInfo.daysSupply.intValue == 30 || self.claimsInfo.daysSupply.intValue == 90 ) {
            shouldCalculate = YES;
        }
        else{
            shouldCalculate = NO;
        }
    }
    
    return shouldCalculate;
}
// Show the view for selecting the sort options
- (IBAction)showSortOptionsView:(id)sender {
    
    if (self.isSearching == NO) {
        _sortOptionsYConstraint.constant = _sortOptionsYConstraint.constant < 0 ? 0 : -200;
    }
    [self.view updateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        ;
    }];
}

// Sort Action
- (IBAction)sortSavingsByType:(id)sender {
    
    UIButton *sortButton = (UIButton*)sender;
    self.sortType = (int)sortButton.tag - 1000;
    _sortOptionsYConstraint.constant = -200;
    [self sortSAvingsListByType:self.sortType];
    
}

// Sort savings by the type selected
- (void)sortSAvingsListByType:(int)type {
    [savingsTableView setContentOffset:CGPointZero];
    noPharmacyView.hidden = YES;
    if (self.sortType == 1) {
        [self sortByDistance];
    }
    else {
        [self sortByPrice];
    }
    [self updateNoPharmacyFoundScreen];
    [self hightlightSelectedSortType:self.sortType];
    
}

//Sort Saving By Distance
- (void)sortByDistance {
    
    NSSortDescriptor *orderType = [[NSSortDescriptor alloc] initWithKey:@"orderType" ascending:YES];
    NSSortDescriptor *distance = [[NSSortDescriptor alloc] initWithKey:@"distance.floatValue" ascending:YES];
    NSArray *sortDescriptors = @[orderType, distance];
    [self.pharmacy sortUsingDescriptors:sortDescriptors];
    [savingsTableView reloadData];
    
}

// Sort Savings By Price
- (void)sortByPrice {
    
    NSSortDescriptor *orderType = [[NSSortDescriptor alloc] initWithKey:@"orderType" ascending:YES];
    NSSortDescriptor *priceSort = [[NSSortDescriptor alloc] initWithKey:@"save.floatValue" ascending:NO];
  //  NSSortDescriptor *errorSort = [[NSSortDescriptor alloc] initWithKey:@"status.intValue" ascending:NO];
    
    //NSArray *sortDescriptors = @[errorSort,priceSort];

    NSArray *sortDescriptors = @[orderType, priceSort];
    [self.pharmacy sortUsingDescriptors:sortDescriptors];
    [savingsTableView reloadData];
    
}

//Highlight the selected sort type
- (void)hightlightSelectedSortType:(int)tag {
    
    int i = 1001;
    
    for (; i < 1003; i++) {
        UIImageView *image = (UIImageView*)[sortOptionsView viewWithTag:i];
        [image setImage:nil];
        
    }
    UIImageView *imageView = (UIImageView*)[sortOptionsView viewWithTag:tag + 1000];
    [imageView setImage:[UIImage imageNamed:@"sort_selected"]];
    
}


- (void)customsiseTextFieldPlaceholder :(UIColor*)placeholderColor withText:(NSString*)placeHolderText{
    
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    } else {
        NSLOG(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
}
// Search By ZipCode Action
- (IBAction)search:(id)sender {
    
    [searchTextField resignFirstResponder];
    searchButton.hidden = YES;
    [hideKeyBoardButton removeFromSuperview];
    
    if (self.isSearching == NO) {
        if ([searchTextField.text length] != MinimumZipCode ) {
            
            searchTextField.text = @"";
            [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
            [EHHelpers showAlertWithTitle:@"" message:@"Please enter a valid ZIP Code." delegate:nil];
            
        }
        else {
            [self fetchSavingPharmacyByZipCode];
        }
        
    }
}

- (IBAction)searchSavingByLocation:(id)sender {
    
    if (self.isSearching == NO) {
        if ([EHHelpers isLocationServiceActive]) {
            
            searchTextField.text =@"";
            [searchTextField resignFirstResponder];
            [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Current Location"];
            
            [self fetchSavingsPharmacyByGPS];
        }
        else{
            [self updateNoPharmacyFoundScreen];
            [EHHelpers showAlertWithTitle:@"" message:@"Please enable the location services to find your savings." delegate:nil];
        }
        
    }
}

- (void)updateNoPharmacyFoundScreen {
    
    BOOL showNoPharmacyScreen = NO;
    
    if ([self.pharmacy count] == 0) {
        self.noPharmacyOriginConstraint.constant = 0;
        showNoPharmacyScreen = YES;
    }
    else if ([self.pharmacy count] >0){
        
        NSArray *filteredArray = [self.pharmacy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderType.intValue == %d",1]];
        if ([filteredArray count] == 0) {
            showNoPharmacyScreen = YES;
            self.noPharmacyOriginConstraint.constant = 150;
        }
        
    }
    [self.view updateConstraints];
    noPharmacyView.hidden = !showNoPharmacyScreen;
    
    
}
- (void)fetchSavingsByLocation {
    
    self.isSearching = NO;
    if ([EHHelpers isLocationServiceActive]) {
        [self fetchSavingsPharmacyByGPS];
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"Please enable the location services to find your savings." delegate:nil];
    }
    
}


// Find Care
- (void)findDetailedSavings {
    
    User *currentUser = [APP_DELEGATE currentUser];
    
    self.isSearching = NO;
    if ([EHHelpers isLocationServiceActive]) {
        [self fetchSavingsPharmacyByGPS];
    }
    else {
        searchTextField.text = @"";
        [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
        
        searchTextField.text = [EHHelpers loadDefaultSettingsForKey:@"zipCode" withDefaultValue:[currentUser.zipCode intValue]];
        if ([searchTextField.text length] >0) {
            [self fetchSavingPharmacyByZipCode];
        }
        else{
            [EHHelpers showAlertWithTitle:@"" message:@"Please enter your ZIP Code to search for the nearest pharmacies." delegate:nil];
            noPharmacyView.hidden = NO;
        }
        
    }
    
}
- (void)fetchSavingPharmacyByZipCode {
    
    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser) {
        NSString *minimumDistance = [EHHelpers loadDefaultSettingsForKey:@"radius" withDefaultValue:DefaultPharmacyRadius] ;
        NSString *maxPharmacy = [EHHelpers loadDefaultSettingsForKey:@"pharmacyCount" withDefaultValue:DefaultNumberOfPharmacy] ;
        
        
        
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetDrugPricingByZipcode", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHDrugPricingByZipCode, currentuser.email, currentuser.guid, self.drugInfo.ndc,self.claimsInfo.quantity.intValue,self.claimsInfo.daysSupply.intValue,minimumDistance,searchTextField.text,maxPharmacy.intValue,AppID];
        
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
        
        if (self.customLoadingView == nil) {
            [self showLoadingView];
        }
        [self.networkOperation fetchPricingByZipCodeWithBody:soapBody forAction:soapAction];
    }else {
        [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
        [self logOutUser];
        
    }
    
}


// Api call for finding pharmacies using gps search
- (void)fetchSavingsPharmacyByGPS {

    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser) {
        self.isSearching = YES;
        NSString *minimumDistance = [EHHelpers loadDefaultSettingsForKey:@"radius" withDefaultValue:DefaultPharmacyRadius] ;
        NSString *maxPharmacy = [EHHelpers loadDefaultSettingsForKey:@"pharmacyCount" withDefaultValue:DefaultNumberOfPharmacy] ;
        
        
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetDrugPricingByLatLong", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHDrugPricingByLatLon, currentuser.email, currentuser.guid,self.drugInfo.ndc,self.claimsInfo.quantity.intValue,self.claimsInfo.daysSupply.intValue,[NSString stringWithFormat:@"%f",[EHLocationService sharedInstance].currentLocation.coordinate.latitude],[NSString stringWithFormat:@"%f",[EHLocationService sharedInstance].currentLocation.coordinate.longitude],minimumDistance,maxPharmacy.intValue,AppID ] ;
        
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
        
        
        if (self.customLoadingView == nil) {
            [self showLoadingView];
        }
        [self.networkOperation fetchPricingByLocationWithBody:soapBody forAction:soapAction];
        ;
    }else {
        [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
        [self logOutUser];
    }
}


- (void)successfullyFetchedPricingDataByLatOrZipCode:(NSArray *)data {
    
    [self.customLoadingView clearAllAnimations];
    [self.customLoadingView removeFromSuperview];
    self.customLoadingView = nil;
    self.isSearching = NO;
    [self addSavingsDetails:data withType:@"1"];
    
}
#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"detailSavingsCellIdentifier";
    
    DetailedSavingCell *cell = (DetailedSavingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailedSavingCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *saveDrug = self.pharmacy[indexPath.row];
    
    cell.titleLabel.text = ( [saveDrug[@"orderType"]intValue] == 0 ) ? @"ORCHARD PHARMACY":saveDrug[@"name"];
    cell.addressLabel.text = ( [saveDrug[@"orderType"]intValue] == 0 ) ? @"Mail Order Pharmacy" :[self pharmaAddressDetails:saveDrug forKeys:@[@"pAddress",@"sAddress",@"city",@"state",@"zip"]];;
    [cell layoutIfNeeded];
    __unused CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    float minimumHeight = ([saveDrug[@"orderType"]intValue] == 0) ? 151 : fmaxf(151, height);
    return minimumHeight;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pharmacy count];
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailedSavingCell *cell = (DetailedSavingCell *)[tableView dequeueReusableCellWithIdentifier:@"detailSavingsCellIdentifier"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailedSavingCell" owner:self options:nil] objectAtIndex:0];
    }
    
    
    NSDictionary *saveDrug = self.pharmacy[indexPath.row];
    cell.contentView.backgroundColor = [saveDrug[@"orderType"] intValue] == 1 ? [UIColor whiteColor] : [UIColor colorWithRed:219.0/255.0 green:220./255.0 blue:211.0/255.0 alpha:1.0];
    
    cell.noPricingMessageLabel.hidden = ([saveDrug[@"hasSavings"] length] == 0) ? NO : YES;
    cell.noPricingMessageLabel.text = ([saveDrug[@"hasSavings"] length] == 0) ? saveDrug[@"errorMessage"] : @"";
    cell.amountLabel.hidden = ([saveDrug[@"hasSavings"] length] == 0) ? YES : NO;
    
    cell.titleLabel.text = ( [saveDrug[@"orderType"]intValue] == 0 ) ? @"ORCHARD PHARMACY" :saveDrug[@"name"];
    cell.addressLabel.text = ( [saveDrug[@"orderType"]intValue] == 0 ) ? @"Mail Order Pharmacy" :[self pharmaAddressDetails:saveDrug forKeys:@[@"pAddress",@"sAddress",@"city",@"state",@"zip"]];;
    
    cell.supplyPayLabel.text = [NSString stringWithFormat:@"Pay $%0.2f for %d day supply",[saveDrug[@"Copay"] floatValue],[saveDrug[@"orderType"] intValue] != 0 ? self.claimsInfo.daysSupply.intValue : 90];
    
    cell.amountLabel.backgroundColor  = [saveDrug[@"save"] floatValue] < 0.0 ? Saving_Red :GREEN_COLOR;
    cell.amountLabel.attributedText = [self attributedTextForPricingText:[NSString stringWithFormat:@"%0.2f",[saveDrug[@"save"] floatValue]] ];
    cell.distanceView.hidden = [saveDrug[@"orderType"] intValue] == 1 ? NO : YES;
    
    cell.supplyPayLabel.backgroundColor = [saveDrug[@"orderType"] intValue] == 1 ? [UIColor whiteColor] : [UIColor colorWithRed:244.0/255.0 green:134.0/255.0 blue:24.0/255.0 alpha:1.0];
    cell.supplyPayLabel.textColor = [saveDrug[@"orderType"] intValue] == 1 ? GREEN_COLOR: [UIColor whiteColor] ;
    cell.distanceLabel.text =  [NSString stringWithFormat:@"%0.2f",[saveDrug[@"distance"] floatValue]];
    cell.showPharmacyDetail.tag = indexPath.row;
    cell.userInteractionEnabled = NO;
    if ([saveDrug[@"orderType"] intValue] == 0 || [saveDrug[@"hasSavings"] length] > 0) {
        cell.userInteractionEnabled = YES;
        [cell.showPharmacyDetail addTarget:self action:@selector(showPharmacyDetail:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    
    int weekday = (int)[comps weekday];
    cell.pharmacyTimeNA.hidden = NO;
    cell.pharmacyTimeNA.text = @"CLOSED";
    if (saveDrug[self.dayKeys[weekday - 1]]) {
        
        NSString *opHours = saveDrug[self.dayKeys[weekday - 1]];
        if (opHours.length > 3) { //check for N/A
            cell.pharmacyTimeNA.text  = [self isPharmacyOpen:opHours] ? @"OPEN" : @"CLOSED";
        }
    }

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (NSAttributedString*)attributedTextForPricingText:(NSString*)pricingValue  {
    
    NSString *mainString = @"";
    
    float saveValue = [pricingValue floatValue];
    int savingsValue = (int)roundf(saveValue);
    
    if(saveValue < 0.0) {
        mainString = [NSString stringWithFormat:@"$%@\nmore\nper year",[EHHelpers commmaSeparatedStringForDigit:savingsValue*-1]];
        savingsValue = savingsValue*-1;
    }
    else{
        mainString = [NSString stringWithFormat:@"Save\n$%@\nper year",[EHHelpers commmaSeparatedStringForDigit:savingsValue]];
    }
    
    NSRange subTextRange = [mainString rangeOfString:[NSString stringWithFormat:@"$%@",[EHHelpers commmaSeparatedStringForDigit:savingsValue]]];
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:mainString];
    NSInteger stringLength=[mainString length];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange( 0,subTextRange.location )];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_BOLD size:(subTextRange.length >=6 )? 16 : 18]
                      range:NSMakeRange(subTextRange.location, subTextRange.length)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange(subTextRange.location + subTextRange.length, stringLength - (subTextRange.location + subTextRange.length) )];
    
    [attString addAttribute:NSForegroundColorAttributeName value: Saving_White range:NSMakeRange(0, stringLength)];
    return attString;
    
}

#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (self.isSearching == YES) {
        return NO;
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    searchButton.hidden = NO;
    [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
    [self addKeyboardButtonToContainerScroll ];
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length > 0 && textField.text.length >= 5)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}

#pragma mark Hide Keyboard

// Initialis the button to tap while editing the custom title for the drug
- (void)initialiseHideKeyboardButton {
    
    hideKeyBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyBoardButton.translatesAutoresizingMaskIntoConstraints = NO;
    hideKeyBoardButton.backgroundColor = [UIColor clearColor];
    [hideKeyBoardButton addTarget:self action:@selector(hideKeyBoardWhileTap) forControlEvents:UIControlEventTouchUpInside];
}

// Hide the key board while tappping outside the keyboard frame
- (void)hideKeyBoardWhileTap {
    
    searchButton.hidden = YES;
    [hideKeyBoardButton removeFromSuperview];
    [searchTextField resignFirstResponder];
    searchTextField.text = @"";
    [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
    
}

- (IBAction)cancelZipCodeSearch:(id)sender {
    
    [self hideKeyBoardWhileTap];
}
// Added button to hide the keyboard while tapping above it
- (void)addKeyboardButtonToContainerScroll {
    
    [self.view addSubview:hideKeyBoardButton];
    NSDictionary *views = NSDictionaryOfVariableBindings(hideKeyBoardButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-108-[hideKeyBoardButton]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[hideKeyBoardButton]|" options:0  metrics:nil views:views]];
    
}


// Show pharmacy in detail
- (void)showPharmacyDetail:(id)sender {
    
    UIButton *pharmaButton = (UIButton*)sender;
    self.selectedPharmacy = [NSDictionary dictionaryWithDictionary:self.pharmacy[pharmaButton.tag]];
    
    [EHHelpers registerGAWithCategory:@"Likely Savings - Pharmacy Details" forAction:[NSString stringWithFormat:@"%@\n%@",self.drugInfo.name,self.selectedPharmacy[@"name"]]];
    if ([self.selectedPharmacy[@"orderType"] intValue] != 0) {
        [self performSegueWithIdentifier:@"showPharmacyDetail" sender:nil];
    }
    else{
        
        OrchardPharmacyViewController *orchardView = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"OrchardPharmacyViewController"];
        orchardView.selectedDrug = self.selectedPharmacy;
        orchardView.showSavings = YES;
        [self.navigationController pushViewController:orchardView animated:YES];
    }
    
}
// Prepare address for the pharmacy
- (NSString*)pharmaAddressDetails:(NSDictionary*)pharmacy forKeys:(NSArray*)keyValues {
    
    NSMutableArray *addressarray = [NSMutableArray array];
    
    for (NSString *phamaKeys  in keyValues) {
        if ([pharmacy[phamaKeys] length] > 0) {
            [addressarray addObject:[EHHelpers stringByRemovingSpecialCharacters:pharmacy[phamaKeys]]];
        }
    }
    return [addressarray count] > 0 ? [addressarray componentsJoinedByString:@", "] : [NSString string];
}

// Segue Delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showPharmacyDetail"]) {
        PharmacyDetailViewController *vc = [segue destinationViewController];
        vc.pharmacyDetail= [NSDictionary dictionaryWithDictionary:self.selectedPharmacy];
        vc.claimsInfo = self.claimsInfo;
        vc.showDrugInfo = YES;
    }
}

//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
