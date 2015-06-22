//
//  FindCareViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 7/24/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "FindCareViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "AFNetworking.h"
#import "XMLReader.h"
#import "DDXML.h"
#import "EHLocationService.h"
@interface FindCareViewController ()

@property (nonatomic ,strong) NSDictionary *selectedPharmacy;
@property (nonatomic ,strong) EHOperation *networkOperation;
@property (nonatomic ,strong) NSArray *dayKeys;
@end

@implementation FindCareViewController
@synthesize pharmacyListArray;

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
    self.screenName = @"Find Pharmacy";
    
    self.selectedPharmacy = [NSDictionary dictionary];
    self.pharmacyListArray = [NSMutableArray array];
    self.isSearching = NO;
    noPharmacyView.hidden = YES;
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [[EHLocationService sharedInstance] startUpdatingLocationService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deactivateKeyBoard) name:@"OpenLeftMenuNotification" object:nil];
    
    // Do any additional setup after loading the view.
    [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
    
    [self addLeftMenuButton];
    [self initialiseHideKeyboardButton];
    [self addNotificationListenerForKeyBoard];
    [self initialiseLoadingView];
    zipCodeSearchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    if ([EHHelpers isNetworkAvailable] == YES) {
        [self findCare];
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"No Network Available" delegate:nil];
    }
  //  pharmacyLisTableView.rowHeight = UITableViewAutomaticDimension;
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.networkOperation cancelOp];
}
- (void)deactivateKeyBoard {
    [zipCodeSearchField resignFirstResponder];
}

- (void)addNotificationListenerForKeyBoard {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

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

- (void)customsiseTextFieldPlaceholder :(UIColor*)placeholderColor withText:(NSString*)placeHolderText{
    
    if ([zipCodeSearchField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        zipCodeSearchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    } else {
        NSLOG(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
}
// Find Care
- (void)findCare {
    User *currentuser = [APP_DELEGATE currentUser];
    
    if ([EHHelpers isLocationServiceActive]) {
        
        self.searchMode = SearchByGPS;
        zipCodeSearchField.text =  @"";
        [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Current Location"];
        [self fetchPharmaciesByGPS];
        
    }
    else {
        
        self.searchMode = SearchByZipCode;
        zipCodeSearchField.text =  @"";
        [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
        
        
        zipCodeSearchField.text = [EHHelpers loadDefaultSettingsForKey:@"zipCode" withDefaultValue:currentuser.zipCode.intValue];
        if ([zipCodeSearchField.text length] > 0) {
            [self fetchPharmaciesByZipCode];
            
        }
        else{
            [EHHelpers showAlertWithTitle:@"" message:@"Please enter your ZIP Code to search for the nearest pharmacies." delegate:nil];
            noPharmacyView.hidden = NO;
        }
    }
    
}

// Search Care
- (IBAction)searchAction:(id)sender {
    
    [hideKeyBoardButton removeFromSuperview];
    [zipCodeSearchField resignFirstResponder];
    
    
    if (self.isSearching == NO) {
        
        if ([zipCodeSearchField.text length] >0 && zipCodeSearchField.text.length == MinimumZipCode) {
            [self fetchPharmaciesByZipCode];
        }
        else {
            zipCodeSearchField.text =  @"";
            [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
            
            [EHHelpers showAlertWithTitle:@"" message:@"Please enter a valid ZIP Code." delegate:nil];
            
        }
        
    }
}

// Find Care by GPS search
- (IBAction)searchByGPS:(id)sender {
    
    [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Current Location"];
    [self hideKeyBoardWhileTap];
    
    [[EHLocationService sharedInstance] startUpdatingLocationService];
    
    self.searchMode = SearchByGPS;
    
    
    if (self.isSearching == NO) {
        if ([EHHelpers isLocationServiceActive]) {
            
            zipCodeSearchField.text = @"";
            zipCodeSearchField.placeholder = @"Current Location";
            [self fetchPharmaciesByGPS];
        }
        else {
            [EHHelpers showAlertWithTitle:@"" message:@"Please activate the location services." delegate:nil];
        }
        
    }
    
}

- (void)hideNoPharmacyScreen {
    
    self.isSearching = YES;
    noPharmacyView.hidden = YES;
    
}

- (void)clearCustomAnimation {
    
    [self.customLoadingView clearAllAnimations];
    [self.customLoadingView removeFromSuperview];
    self.customLoadingView = nil;
    self.isSearching = NO;

}
// Api call for finding pharmacies using gps search
- (void)fetchPharmaciesByGPS {
    
    if ([EHHelpers isNetworkAvailable]) {
        
        User *currentuser = [APP_DELEGATE currentUser];
        if (currentuser) {
            [self hideNoPharmacyScreen];
            ;
            
            NSString *lat =  [NSString stringWithFormat:@"%f",[[EHLocationService sharedInstance] currentLocation].coordinate.latitude];
            NSString *lon = [NSString stringWithFormat:@"%f",[[EHLocationService sharedInstance] currentLocation].coordinate.longitude];
            NSString *minimumDistance = [EHHelpers loadDefaultSettingsForKey:@"radius" withDefaultValue:DefaultPharmacyRadius] ;
            NSString *maxPharmacy = [EHHelpers loadDefaultSettingsForKey:@"pharmacyCount" withDefaultValue:DefaultNumberOfPharmacy] ;
            
            
            
            NSString *soapAction = [NSString stringWithFormat:@"%@/GetPharmaciesByLatLong", API_ACTION_ROOT];
            NSString *soapBodyXML = [NSString stringWithFormat:EHGetPharmaciesByLatLon, currentuser.email, currentuser.guid,lat,lon, minimumDistance , [maxPharmacy intValue], AppID] ;
            
            NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
            [self showLoadingView];
            [self.networkOperation findCareWithBody:soapBody forAction:soapAction];
            

        }else {
            [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
            [self logOutUser];
        }
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"No Network Available" delegate:nil];
    }
}

- (void)logOutUser {
    
    [APP_DELEGATE setCurrentUser:nil];
    [APP_DELEGATE stopSessionTimer];
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC.leftMenu performSegueWithIdentifier:@"showMedicineCabinetSegue" sender:nil];
}
// Api call for finding pharmacies using zipcode search

- (void)fetchPharmaciesByZipCode {
    
    if ([EHHelpers isNetworkAvailable]) {
        User *currentuser = [APP_DELEGATE currentUser];
        
        if (currentuser) {
            self.isSearching = YES;
            
            NSString *minimumDistance = [EHHelpers loadDefaultSettingsForKey:@"radius" withDefaultValue:DefaultPharmacyRadius] ;
            NSString *maxPharmacy = [EHHelpers loadDefaultSettingsForKey:@"pharmacyCount" withDefaultValue:DefaultNumberOfPharmacy] ;
            NSString *soapAction = [NSString stringWithFormat:@"%@/GetPharmacies", API_ACTION_ROOT];
            NSString *soapBodyXML = [NSString stringWithFormat:EHGetPharmacies, currentuser.email, currentuser.guid, zipCodeSearchField.text,minimumDistance,[maxPharmacy intValue], AppID];
            
            NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2,soapBodyXML];
            [self showLoadingView];
            [self.networkOperation findCareWithBody:soapBody forAction:soapAction];
            
        }else {
            [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
            [self logOutUser];
        }
        
    }
    else {
        [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
    }
    
}


#pragma mark CareData Response Delegate

- (void)successFullyFetchedCareData:(NSArray *)data {
    
    [self populatePharmacy:data];
    [self clearCustomAnimation];
    
}

- (void)error:(NSError *)operationError {
   
    [self clearCustomAnimation];
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
        if ([errorMessage isEqualToString:@"Invalid GUID. Please log in again"]) {
            [self logOutUser];
        }
    }

}
// Populating the zip code pharmacy details
- (void)populatePharmacy:(NSArray *)pharmacies {
    self.dayKeys = [NSArray arrayWithObjects:@"sunHrs", @"monHrs", @"tueHrs", @"wedHrs", @"thuHrs", @"friHrs", @"satHrs",nil];
    [zipCodeSearchField resignFirstResponder];
    [self clearPharmacyList];
    [pharmacyLisTableView setContentOffset:CGPointZero];
    
    for (DDXMLElement *pharmacy in pharmacies) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"name"] = [EHHelpers stringByRemovingSpecialCharacters:[EHHelpers xmlElementValueForKey:@"PHARMACYNAME" forXmlElement:pharmacy]];
        dic[@"nabp"] =  [EHHelpers xmlElementValueForKey:@"NABP" forXmlElement:pharmacy];
        dic[@"pAddress"] = [EHHelpers xmlElementValueForKey:@"PHARMADDR1" forXmlElement:pharmacy];
        dic[@"sAddress"] = [EHHelpers xmlElementValueForKey:@"PHARMADDR2" forXmlElement:pharmacy];
        dic[@"city"] = [EHHelpers xmlElementValueForKey:@"PHARMCITY" forXmlElement:pharmacy];
        dic[@"state"] = [EHHelpers xmlElementValueForKey:@"PHARMSTATE" forXmlElement:pharmacy];
        dic[@"zip"] = [EHHelpers stringByRemovingSpecialCharacters:[EHHelpers xmlElementValueForKey:@"PHARMZIP" forXmlElement:pharmacy]];
        dic[@"phone"] = [EHHelpers xmlElementValueForKey:@"PHONE" forXmlElement:pharmacy];
        dic[@"lat"] = [EHHelpers xmlElementValueForKey:@"LATITUDE" forXmlElement:pharmacy];
        dic[@"lon"] = [EHHelpers xmlElementValueForKey:@"LONGITUDE" forXmlElement:pharmacy];
        dic[@"distance"] = [EHHelpers xmlElementValueForKey:@"DISTANCE" forXmlElement:pharmacy];
        
        dic[@"dispType"] = [EHHelpers xmlElementValueForKey:@"DISPTYPE" forXmlElement:pharmacy];
        dic[@"dispClass"] = [EHHelpers xmlElementValueForKey:@"DISPCLASS" forXmlElement:pharmacy];
        dic[@"icon"] = [EHHelpers xmlElementValueForKey:@"ICON" forXmlElement:pharmacy];
       
        dic[@"monHrs"] = [EHHelpers xmlElementValueForKey:@"MONHOURS" forXmlElement:pharmacy];
        dic[@"tueHrs"] = [EHHelpers xmlElementValueForKey:@"TUEHOURS" forXmlElement:pharmacy];
        dic[@"wedHrs"] = [EHHelpers xmlElementValueForKey:@"WEDHOURS" forXmlElement:pharmacy];
        dic[@"thuHrs"] = [EHHelpers xmlElementValueForKey:@"THUHOURS" forXmlElement:pharmacy];
        dic[@"friHrs"] = [EHHelpers xmlElementValueForKey:@"FRIHOURS" forXmlElement:pharmacy];
        dic[@"satHrs"] = [EHHelpers xmlElementValueForKey:@"SATHOURS" forXmlElement:pharmacy];
        dic[@"sunHrs"] = [EHHelpers xmlElementValueForKey:@"SUNHOURS" forXmlElement:pharmacy];
        
        dic[@"retail"] = [EHHelpers xmlElementValueForKey:@"RETAIL90" forXmlElement:pharmacy];
        dic[@"vaccNetwork"] = [EHHelpers xmlElementValueForKey:@"VACCINENETWORK" forXmlElement:pharmacy];
        
        
        [self.pharmacyListArray addObject:dic];
    }
    [self updateUIWithDistanceSort];
    
}


#pragma mark
#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (self.isSearching == YES) {
        return NO;
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self addKeyboardButtonToContainerScroll ];
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self findPharmacy];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (self.isSearching) {
        return NO;
    }
    if (string.length > 0 && textField.text.length >= 5)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}

// Remove previous pharmacy list data
- (void)clearPharmacyList {
    
    if ([self.pharmacyListArray count] != 0 ) {
        [self.pharmacyListArray removeAllObjects];
    }
    
}

// Update UI with data sorted with distance
- (void)updateUIWithDistanceSort {
    
    self.isSearching = NO;
    noPharmacyView.hidden = YES;
    //zipCodeSearchField.text = @"";
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance.floatValue" ascending:YES];
    self.pharmacyListArray = [NSMutableArray arrayWithArray:[self.pharmacyListArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    if (self.pharmacyListArray.count  == 0) {
        
        noPharmacyView.hidden = NO;
    }
    [pharmacyLisTableView reloadData];
    
}
#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pharmacyListArray count];
}

////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"pharmCellIdentifier";
    
    PharmacyCellTableViewCell *cell = (PharmacyCellTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PharmacyCellTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *pharmaDict = self.pharmacyListArray[indexPath.row];
    
    cell.pharmName.text = [EHHelpers stringByRemovingSpecialCharacters:pharmaDict[@"name"]];
    cell.pharmaStreetLabel.text = [self pharmaAddressDetails:pharmaDict forKeys:@[@"pAddress",@"sAddress"]];
    
    cell.addressLabel.text = [self pharmaAddressDetails:pharmaDict forKeys:@[@"city",@"state",@"zip"]];
    cell.pharmaDistance.text = [NSString stringWithFormat:@"%0.2f Miles",[pharmaDict[@"distance"] floatValue]];
    [cell layoutIfNeeded];
    __unused CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return fmaxf( height+20 + 1,92);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PharmacyCellTableViewCell *pharmaCell = (PharmacyCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"pharmCellIdentifier"];
    if (!pharmaCell) {
        pharmaCell = [[[NSBundle mainBundle] loadNibNamed:@"PharmacyCellTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    NSDictionary *pharmaDict = self.pharmacyListArray[indexPath.row];
    
    pharmaCell.pharmName.text = [EHHelpers stringByRemovingSpecialCharacters:pharmaDict[@"name"]];
    pharmaCell.pharmaStreetLabel.text = [self pharmaAddressDetails:pharmaDict forKeys:@[@"pAddress",@"sAddress"]];
    pharmaCell.addressLabel.text = [self pharmaAddressDetails:pharmaDict forKeys:@[@"city",@"state",@"zip"]];
    pharmaCell.pharmaDistance.text = [NSString stringWithFormat:@"%0.2f Miles",[pharmaDict[@"distance"] floatValue]];
  
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    
    int weekday = (int)[comps weekday];
    pharmaCell.pharmTimeNA.hidden = NO;
    pharmaCell.pharmTimeNA.text = @"CLOSED";
    if (self.pharmacyListArray[indexPath.row][self.dayKeys[weekday - 1]]) {
        
        NSString *opHours = self.pharmacyListArray[indexPath.row][self.dayKeys[weekday - 1]];
        if (opHours.length > 3) { //check for N/A
            pharmaCell.pharmTimeNA.text = [self isPharmacyOpen:opHours] ? @"OPEN" : @"CLOSED";
        }
    }
    
    return pharmaCell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pharmacyDetails"]) {
        
        // Get destination view
        PharmacyDetailViewController *vc = [segue destinationViewController];
        vc.pharmacyDetail= [NSDictionary dictionaryWithDictionary:self.pharmacyListArray[[pharmacyLisTableView indexPathForSelectedRow].row]];
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



- (void)findPharmacy {
    
    [self fetchPharmaciesByZipCode];
}
// Initialis the button to tap while editing the custom title for the drug
- (void)initialiseHideKeyboardButton {
    
    hideKeyBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyBoardButton.translatesAutoresizingMaskIntoConstraints = NO;
    hideKeyBoardButton.backgroundColor = [UIColor clearColor];
    [hideKeyBoardButton addTarget:self action:@selector(hideKeyBoardWhileTap) forControlEvents:UIControlEventTouchUpInside];
}

// Hide the key board while tappping outside the keyboard frame
- (void)hideKeyBoardWhileTap {
    
    [hideKeyBoardButton removeFromSuperview];
    [zipCodeSearchField resignFirstResponder];
    zipCodeSearchField.text = @"";
    [self customsiseTextFieldPlaceholder:PlaceHolderColor withText:@"Enter ZIP Code"];
}


// Add button to scroll container to dismiss the keyboard while tapping outside the keyboard
- (void)addKeyboardButtonToContainerScroll {
    
    [self.view addSubview:hideKeyBoardButton];
    NSDictionary *views = NSDictionaryOfVariableBindings(hideKeyBoardButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-108-[hideKeyBoardButton]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[hideKeyBoardButton]|" options:0  metrics:nil views:views]];
    
}

- (IBAction)cancelSearchByZipCode:(id)sender {
    
    [self hideKeyBoardWhileTap];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showMenu {
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}
@end
