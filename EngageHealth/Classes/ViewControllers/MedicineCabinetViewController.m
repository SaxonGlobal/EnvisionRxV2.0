//
//  MedicineCabinetViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 21/07/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MedicineCabinetViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "RenewRefillViewController.h"
#import "NSString+Mobomo.h"
#import "AFNetworking.h"
#import "XMLReader.h"
#import "DDXML.h"
#import "Claims.h"
#import "Drugs.h"
#import "Bugsnag.h"

#define kUserDefinedDrugs @"kUserDefinedDrugs"
#define HEADER_TEXT @"   MEDICINE CABINET"
#define HEADER_HEIGHT 37
#define CELL_HEIGHT 134
#define ADD_DRUG_CONTAINER_HEIGHT 47
#define AlarmActiveColor [UIColor colorWithRed:28.0/255.0 green:77.0/255.0 blue:111.0/255.0 alpha:1.0]
#define AlarmInActiveColor [UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0]

@implementation MedicineCabinetViewController
@synthesize addDrugHeightConstraint;
@synthesize selectedMedicine;
@synthesize deleteManualDrugOptionViewConstraint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Medicine Cabinet";
    self.selectedMedicine = [NSDictionary dictionary];
    homePreviewImage.hidden = YES;
    homePreviewImage.alpha = 0.0;
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deactivateKeyBoard) name:@"OpenLeftMenuNotification" object:nil];

    [self initialiseHideKeyboardButton];

    if (![APP_DELEGATE currentUser]) {
        homePreviewImage.hidden = NO;
        homePreviewImage.alpha = 1.0;
    }

    // Do any additional setup after loading the view, typically from a nib.
    deleteOptionsView.hidden = YES;
    deleteOptionsView.alpha = 0.0;
    
    [medicinesTableView setBackgroundColor:[UIColor clearColor]];
    [medicinesTableView setBackgroundView:nil];
    self.addDrugHeightConstraint.constant = 0;
    self.deleteManualDrugOptionViewConstraint.constant = 0;
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    self.medicinesListArray = [NSMutableArray array];
    [self createEmptyCabinetView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"_Logout_TimeOut_" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (![APP_DELEGATE currentUser]) {
        homePreviewImage.hidden=NO;
        homePreviewImage.alpha = 1.0;
        
        [self.view.window.rootViewController performSegueWithIdentifier:@"showLoginVC" sender:nil];
        return;
    }
    homePreviewImage.hidden=YES;
    [self isFirstTimeLoggingIn];
    [self populateMedicineData];
}

#pragma mark 
#pragma Handle Keyboard

- (void)initialiseHideKeyboardButton {
    
    hideKeyBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyBoardButton.translatesAutoresizingMaskIntoConstraints = NO;
    hideKeyBoardButton.backgroundColor = [UIColor clearColor];
    [hideKeyBoardButton addTarget:self action:@selector(hideKeyBoardWhileTap) forControlEvents:UIControlEventTouchUpInside];
}

// Hide the key board while tappping outside the keyboard frame
- (void)hideKeyBoardWhileTap {
    
    [drugAddField resignFirstResponder];
    [hideKeyBoardButton removeFromSuperview];
}


// Add button to scroll container to dismiss the keyboard while tapping outside the keyboard
- (void)addKeyboardButtonToContainer{
    
    [self.view addSubview:hideKeyBoardButton];
    NSDictionary *views = NSDictionaryOfVariableBindings(hideKeyBoardButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-111-[hideKeyBoardButton]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[hideKeyBoardButton]|" options:0  metrics:nil views:views]];
    
}

- (void)deactivateKeyBoard {
    [drugAddField resignFirstResponder];
    addDrugButton.selected = YES;
    [self showHideSearch];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self addKeyboardButtonToContainer ];
}
- (void)logout {
    [self.view.window.rootViewController performSegueWithIdentifier:@"showLoginVC" sender:nil];
}

#pragma mark
// Checks if the user is logging the app for the first time . If true, the user is shown the getting started view which run through the app features else shown the claims history
- (void)isFirstTimeLoggingIn {
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *loginKey = [NSString stringWithFormat:@"isFirstLogged-%@",currentuser.memberId];
        if (![defaults objectForKey:loginKey]) {
            [EHHelpers syncDefaults:loginKey dataToSync:@"1"];
            [self showGettingStartedView];
        }
    }
}

#pragma mark
#pragma mark GettingStartedView
// Show the get started screen. This screen gives a highlight of the app features and tutorial to use the app
- (void)showGettingStartedView {
    
    GettingStartedView *startingView = [[GettingStartedView alloc] init];
    startingView.delegate =self;
    startingView.translatesAutoresizingMaskIntoConstraints = NO;
    startingView.tag = GettingStartedScreenTag;
    [self.view addSubview:startingView];
    self.topConstraint = [NSLayoutConstraint constraintWithItem:startingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:startingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:startingView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:startingView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.view addConstraint:self.topConstraint];
    [self.view addConstraint:heightConstraint];
    [self.view addConstraint:leftConstraint];
    [self.view addConstraint:rightConstraint];
    [self.view updateConstraints];
    [startingView loadHtml];
}



// Removes the getting started screen from the view hierarchy
- (void)removeGetStartedView {
    
    GettingStartedView *startingView = (GettingStartedView*)[self.view viewWithTag:GettingStartedScreenTag];
    [startingView removeConstraint:self.topConstraint];
    self.topConstraint.constant = self.view.frame.size.height;
    [self.view addConstraint:self.topConstraint];
    [self.view updateConstraints];
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        ;
    }];
}

// Action called while tapping the get started button
- (void)getStarted {
    [self removeGetStartedView];
}

#pragma mark
#pragma mark EmptyCabinet

// Create an empty cabinet screen, this screen is shown when there is no claim's details for the respective user
- (void)createEmptyCabinetView {
    
    emptyCabinetView = [[NoDrugView alloc] init];
    emptyCabinetView.translatesAutoresizingMaskIntoConstraints = NO;
    emptyCabinetView.hidden = YES;
    [self.view addSubview:emptyCabinetView];
    NSLayoutConstraint *topOriginConstraint = [NSLayoutConstraint constraintWithItem:emptyCabinetView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:medicinesTableView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:emptyCabinetView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-64];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:emptyCabinetView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:emptyCabinetView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.view addConstraint:topOriginConstraint];
    [self.view addConstraint:heightConstraint];
    [self.view addConstraint:leftConstraint];
    [self.view addConstraint:rightConstraint];
    [self.view updateConstraints];
    
}

// Adds the claims history data, manual drug data, updates the alerts active/inactive status, and prepare the list
- (void)prepareMedicineCabinetView {
    
    NSArray *claimsHistory = [NSArray arrayWithArray:[[APP_DELEGATE currentUser] currentUserClaims]];
    [self.medicinesListArray addObjectsFromArray:claimsHistory];
    
    [self addManualDrugs];
    [self updateAlertsForDrug];
    [medicinesTableView reloadData];

}

// Checks the last updated date of the claims history. New data updated once in a day.
- (BOOL)updateRecentMedicineData {
    
    BOOL shouldUpdate = YES;
    
    User *currentuser = [APP_DELEGATE currentUser];

    NSString *medCacheKey = [NSString stringWithFormat:@"%@-%@",currentuser.email,MedicineCabinetUpdatedDate];
    
    if ([[currentuser currentUserClaims] count] > 0 && [[NSUserDefaults standardUserDefaults] objectForKey:medCacheKey]) {
        NSDate *lastUpdateDate = [EHHelpers dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:medCacheKey]];
        if ([[NSDate date] timeIntervalSinceDate:lastUpdateDate] < DAY_IN_SECONDS) {
            shouldUpdate = NO;
        }
    }

    return shouldUpdate;
}
#pragma mark
#pragma mark Populate Claims

// API call for loading medicine data for user
- (void)populateMedicineData {
    
    emptyCabinetView.hidden = YES;
    User *currentuser = [APP_DELEGATE currentUser];
    self.medicinesListArray = [NSMutableArray array];
    
    if (currentuser) {

        [self prepareMedicineCabinetView];
        
        if ([self updateRecentMedicineData] == YES) {
           
            NSString *soapAction = [NSString stringWithFormat:@"%@/ClaimsHistory", API_ACTION_ROOT];
            NSString *soapBodyXML = [NSString stringWithFormat:EHClaims, currentuser.email, currentuser.guid, currentuser.personCode.intValue,[[EHHelpers stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(MONTH_IN_SECONDS* 18)] format:sqliteDateFormat] stringByActuallyAddingURLEncoding], [[EHHelpers stringFromDate:[NSDate date] format:sqliteDateFormat] stringByActuallyAddingURLEncoding],AppID];
            
            NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2,  soapBodyXML];
            [self.networkOperation fetchUserClaimsWithBody:soapBody forAction:soapAction];

        }
    }
}

#pragma mark
#pragma mark UserClaimsDataDelegate

- (void)successfullyfetchedUserClaimsData:(NSArray *)data {

    [self prepareClaimsHistoryForCurrentUserWithData:data];
    [self addManualDrugs];
    [self updateAlertsForDrug];
    if ([self.medicinesListArray count] == 0) {
        [self showNoClaimsView];
    }
    [medicinesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (void)error:(NSError *)operationError {
    
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
    }
    
}

- (void)showNoClaimsView {
    
    emptyCabinetView.hidden = NO;
}


- (void)prepareClaimsHistoryForCurrentUserWithData:(NSArray*)claims {
    
    User *currentuser = [APP_DELEGATE currentUser];
    
    NSMutableArray *userClaims = [NSMutableArray array];
    
    if (currentuser) {
        
        for (DDXMLElement *claimElement in claims) {
            NSMutableDictionary *claimDictionary = [NSMutableDictionary dictionary];
            
            claimDictionary[@"RxNumber"] = [EHHelpers xmlElementValueForKey:@"RxNumber" forXmlElement:claimElement];
            claimDictionary[@"FillDate"] = [EHHelpers dateFromString:[EHHelpers xmlElementValueForKey:@"FillDate" forXmlElement:claimElement]];
            claimDictionary[@"Quantity"] = [EHHelpers xmlElementValueForKey:@"Quantity" forXmlElement:claimElement];
            claimDictionary[@"DaysSupply"] = [EHHelpers xmlElementValueForKey:@"DaysSupply" forXmlElement:claimElement];
            claimDictionary[@"PrescriberID"] = [EHHelpers xmlElementValueForKey:@"PrescriberID" forXmlElement:claimElement];
            claimDictionary[@"PrescriberName"] = [EHHelpers xmlElementValueForKey:@"PrescriberName" forXmlElement:claimElement];
            claimDictionary[@"PharmacyID"] = [EHHelpers xmlElementValueForKey:@"PharmacyID" forXmlElement:claimElement];
            claimDictionary[@"PlanPaid"] = [EHHelpers xmlElementValueForKey:@"PlanPaid" forXmlElement:claimElement];
            claimDictionary[@"MemberPaid"] = [EHHelpers xmlElementValueForKey:@"MemberPaid" forXmlElement:claimElement];
            claimDictionary[@"TotalPrice"] = [EHHelpers xmlElementValueForKey:@"TotalPrice" forXmlElement:claimElement];
            claimDictionary[@"DAW"] = [EHHelpers xmlElementValueForKey:@"DAW" forXmlElement:claimElement];
            claimDictionary[@"Refillable"] = [EHHelpers xmlElementValueForKey:@"Refillable" forXmlElement:claimElement];
            claimDictionary[@"Reversed"] = [EHHelpers xmlElementValueForKey:@"Reversed" forXmlElement:claimElement];
            
            DDXMLElement *drugElement = [claimElement elementsForName:@"Drug"][0];
            
            NSMutableDictionary *drug = [NSMutableDictionary dictionary];
            drug[@"NDCUPCHRI"] = [EHHelpers xmlElementValueForKey:@"NDCUPCHRI" forXmlElement:drugElement];
            drug[@"ALTNDC"] = [EHHelpers xmlElementValueForKey:@"ALTNDC" forXmlElement:drugElement];
            drug[@"PRODDESCABBREV"] = [EHHelpers xmlElementValueForKey:@"PRODDESCABBREV" forXmlElement:drugElement];
            drug[@"ALTDRUGNAME"] = [EHHelpers xmlElementValueForKey:@"ALTDRUGNAME" forXmlElement:drugElement];
            drug[@"STRENGTH"] = [EHHelpers xmlElementValueForKey:@"STRENGTH" forXmlElement:drugElement];
            drug[@"STRENGTHUOM"] = [EHHelpers xmlElementValueForKey:@"STRENGTHUOM" forXmlElement:drugElement];
            drug[@"MULTISOURCE"] = [EHHelpers xmlElementValueForKey:@"MULTISOURCE" forXmlElement:drugElement];
            drug[@"TYPE"] = [EHHelpers xmlElementValueForKey:@"TYPE" forXmlElement:drugElement];
            drug[@"PACKAGESIZE"] = [EHHelpers xmlElementValueForKey:@"PACKAGESIZE" forXmlElement:drugElement];
            drug[@"PRODNAME"] = [EHHelpers xmlElementValueForKey:@"PRODNAME" forXmlElement:drugElement];
            drug[@"GPI"] = [EHHelpers xmlElementValueForKey:@"GPI" forXmlElement:drugElement];
            drug[@"DOSAGEFORM"] = [EHHelpers xmlElementValueForKey:@"DOSAGEFORM" forXmlElement:drugElement];
            drug[@"OTC"] = [EHHelpers xmlElementValueForKey:@"OTC" forXmlElement:drugElement];
            drug[@"INGREDIENT"] = [EHHelpers xmlElementValueForKey:@"INGREDIENT" forXmlElement:drugElement];
            
            claimDictionary[@"Drug"]= [NSDictionary dictionaryWithDictionary:drug];
            [userClaims addObject:claimDictionary];
        }
    }
    // Find the drugs that were reveresed
    NSArray *reversedClaims = [userClaims filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Reversed.boolValue == YES"]];
    
    // If any drug is reversed deleted all the details regarding that drug with RxNumber and fillDate
    if ([reversedClaims count] > 0) {
       
        [userClaims removeObjectsInArray:reversedClaims];
        for (NSDictionary *details in reversedClaims) {
            
            NSArray *reveresedFilteredClaims = [userClaims filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(RxNumber == %@) AND (FillDate == %@)",details[@"RxNumber" ],details[@"FillDate"]]]    ;
            if ([reveresedFilteredClaims count] > 0) {
                [userClaims removeObjectsInArray:reveresedFilteredClaims];
                
            }
        }
    }
    
    
    NSMutableArray *claimsHistory = [NSMutableArray arrayWithArray:userClaims];
    [userClaims removeAllObjects];
    
    // A medicine can be bought from different pharmacy ,Filter the date by latest fill date
    for (NSDictionary *claimsDic in claimsHistory) {
        NSArray *filteredArray = [claimsHistory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Drug.PRODDESCABBREV == %@",claimsDic[@"Drug"][@"PRODDESCABBREV"]]];
        if ([filteredArray count]>0) {
            filteredArray =  [filteredArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"FillDate" ascending:NO]]];
            if (![userClaims containsObject:filteredArray[0]]) {
                [userClaims addObject:filteredArray[0]];
            }
        }
        
    }
    [userClaims sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"FillDate" ascending:NO]]];
    [self updateClaimDB:userClaims];
    
}

- (void)updateClaimDB:(NSArray*)claims {
    
    [self.medicinesListArray removeAllObjects];
    User *currentuser = [APP_DELEGATE currentUser];
    
    NSManagedObjectContext *const ctx = [APP_DELEGATE managedObjectContext];
    if (currentuser) {
        if ([claims count] > 0) {
            
            NSString *medCacheKey = [NSString stringWithFormat:@"%@-%@",currentuser.email,MedicineCabinetUpdatedDate];
            
            [[NSUserDefaults standardUserDefaults] setObject:[EHHelpers stringFromDate:[NSDate date] format:sqliteDateFormat] forKey:medCacheKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [currentuser removeClaim:currentuser.claim];
            
        }
        
        for (NSDictionary *claimElement in claims) {
            
            Claims *claim = [Claims insertNewClaimData:claimElement];
            [currentuser addClaimObject:claim];
        }
        [ctx save:nil];
    }
    
    self.medicinesListArray = [NSMutableArray arrayWithArray:[currentuser currentUserClaims]];
    
    if ([self.medicinesListArray count] > 0) {
        emptyCabinetView.hidden = YES;
    }
    [medicinesTableView reloadData];
    
}

#pragma mark
#pragma mark Manual Drug Addition

// Add manual drugs to the drug lists
- (void)addManualDrugs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *drugArray = [defaults objectForKey:[self loggedInUserKey]] ? [NSArray arrayWithArray:[defaults objectForKey:[self loggedInUserKey]]] : [NSArray array];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.medicinesListArray];
    [tempArray removeObjectsInArray:drugArray];
    [self.medicinesListArray removeAllObjects];
    [self.medicinesListArray addObjectsFromArray:drugArray];
    [self.medicinesListArray addObjectsFromArray:tempArray];
    
    if ([self.medicinesListArray count] > 0) {
        emptyCabinetView.hidden = YES;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.medicinesListArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id medInfo = self.medicinesListArray[indexPath.row];
    BOOL manualDrug = ![medInfo isKindOfClass:[Claims class]];
    
    float manualDrugHeight = 0;
    if (manualDrug) {
        static NSString *CellIdentifier = @"Med_Cabinet_Manual_Drug_Cell_Identifier";
        
        MedicineCabinetManualCell *cell = (MedicineCabinetManualCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MedicineCabinetManualCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }
        
        id medInfo = self.medicinesListArray[indexPath.row];
       NSString *drugName = medInfo [@"drugName"];
        cell.drugNameLabel.text = drugName;

        [cell layoutIfNeeded];
        __unused CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        manualDrugHeight =  fmaxf( height + 1,40);

    }
    return manualDrug ? manualDrugHeight : CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_HEIGHT)];
    [headerView setBackgroundColor:BLUE_COLOR];
    //    0, 85, 125

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
    headerLabel.text = HEADER_TEXT;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = GREEN_COLOR;
    headerLabel.font = [UIFont fontWithName:APPLICATION_FONT_BOLD size:19.0];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id medInfo = self.medicinesListArray[indexPath.row];
    BOOL manualDrug = ![medInfo isKindOfClass:[Claims class]];
    
    NSString *cellIdentifier = manualDrug ? @"Med_Cabinet_Manual_Drug_Cell_Identifier" : @"Med_Cabinet_Cell_Identifier";
    MedicineCabinetCell *medCell = (MedicineCabinetCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!medCell) {
        medCell = [[[NSBundle mainBundle] loadNibNamed:@"MedicineCabinetCell" owner:self options:nil] objectAtIndex:0];
    }
    
    medCell.cellDelegate = self;
    int drugQuantity = 0;
    
    NSString *drugName = @"";
    
    if (!manualDrug) {
        Claims *claimObj = (Claims *)medInfo;
        Drugs *drugObj = claimObj.drug;
        
        drugName = drugObj.proddescabbrev;
        medCell.drugAmountLabel.text = [NSString stringWithFormat:@"You Paid: $%0.2f", [claimObj.memberPaid floatValue]];
        
        drugQuantity =  claimObj.daysSupply.intValue;
        float timeInterval = [claimObj.fillDate timeIntervalSinceNow];
        
        timeInterval = timeInterval + DAY_IN_SECONDS*drugQuantity;
        
        int drugDaysRemaining =  roundf(timeInterval/DAY_IN_SECONDS);
        medCell.refillAlertView.hidden = YES;
        medCell.refillNormalView.hidden = YES;
        medCell.refillWarningView.hidden = YES;
        medCell.refillAlertDaysLeft.text = @"";
        medCell.refillNormalDaysLeft.text = @"";
        
        
        NSString *daysLeftText = @"RENEW NOW";
        
        if (drugDaysRemaining > 0) {
            
            medCell.daysLeftLabel.hidden = NO;
            daysLeftText = drugDaysRemaining == 1 ? @"Day Left" : @"Days Left";
            medCell.refillNormalView.hidden = NO;
            
            if (drugDaysRemaining <= 5) {
                medCell.refillAlertView.hidden = NO;
                medCell.refillNormalView.hidden = YES;
            }
            
            medCell.refillNormalDaysLeft.attributedText = [self attributedTextForDays:drugDaysRemaining withDaysRemainingText:[NSString stringWithFormat:@"%d\n%@", drugDaysRemaining, daysLeftText]];
            medCell.refillAlertDaysLeft.attributedText = [self attributedTextForDays:drugDaysRemaining withDaysRemainingText:[NSString stringWithFormat:@"%d\n%@", drugDaysRemaining, daysLeftText]];
            
        }
        else {
            medCell.refillWarningView.hidden = NO;
        }
        medCell.drugNameLabel.text = drugName;
        medCell.alarmStatusButton.selected = [AlertHandler hasAnyActiveAlertsForDrug:drugName];
        NSString *alarmStatusImage = ([AlertHandler hasAnyActiveAlertsForDrug:drugName] == YES ) ? @"alarm_on" : @"alarm_off";
        
        [medCell.alarmStatusButton setImage:[UIImage imageNamed:alarmStatusImage] forState:UIControlStateNormal];
        [medCell.alarmStatusButton setImage:[UIImage imageNamed:alarmStatusImage] forState:UIControlStateSelected];
        
        medCell.savingButton.tag =  indexPath.row;
        
        [medCell.savingButton addTarget:self action:@selector(showMySaving:) forControlEvents:UIControlEventTouchUpInside];
        medCell.savingsLabel.text = [self getSavingsForDrug:claimObj];
        
        medCell.alarmStatusButton.tag = AlarmButtonTagOffset + indexPath.row;
        medCell.renewRefillButton.tag = AlarmButtonTagOffset + indexPath.row;
        medCell.alarmStatusButton.backgroundColor = ([AlertHandler hasAnyActiveAlertsForDrug:drugName] == YES ) ? AlarmActiveColor : AlarmInActiveColor;
        return medCell;
    }
    else{
        drugName = medInfo [@"drugName"];
    }
    BOOL isAlarmActive = [AlertHandler hasAnyActiveAlertsForDrug:drugName];
    
    MedicineCabinetManualCell *medManualCell = (MedicineCabinetManualCell *)medCell;
    medManualCell.deleteManualDrug.tag = AlarmButtonTagOffset + indexPath.row;
    
    medManualCell.drugNameLabel.text = drugName;
    medManualCell.alarmStatusButton.selected = [AlertHandler hasAnyActiveAlertsForDrug:drugName];
    medManualCell.alarmStatusButton.tag = AlarmButtonTagOffset + indexPath.row;
    medManualCell.alarmStatusButton.backgroundColor = (isAlarmActive == YES ) ? AlarmActiveColor : AlarmInActiveColor;
    medManualCell.clockBgLabel.backgroundColor = (isAlarmActive == YES ) ? AlarmActiveColor : AlarmInActiveColor;
    return medManualCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSAttributedString*)attributedTextForDays:(int)daysLeft withDaysRemainingText:(NSString*)daysLeftString {
    
    NSRange range = [daysLeftString rangeOfString:[NSString stringWithFormat:@"%d",daysLeft]];
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:daysLeftString];
    NSInteger stringLength=[daysLeftString length];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange( 0,range.location )];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_BOLD size:18]
                      range:NSMakeRange(range.location, range.length)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange(range.location + range.length, stringLength - (range.location + range.length) )];
    
    [attString addAttribute:NSForegroundColorAttributeName value:Saving_White range:NSMakeRange(0, stringLength)];
    return attString;
    
}


#pragma mark
#pragma mark Delete Manual Drug

// Manually added drug can be deleted from the claims. The option to delete or cancel the selection the screen is shown with the delete options view
- (void)showDeleteOptionsView {
    
    [UIView animateWithDuration:0.3 animations:^{
        deleteOptionsView.hidden = NO;
        deleteOptionsView.alpha = 1.0;
        
    }];
}

// Undo delete manual drug selection
- (IBAction)undoManualDrugDeletion:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.deleteManualDrugOptionViewConstraint.constant = 0;
        deleteOptionsView.hidden = YES;
        deleteOptionsView.alpha = 0.0;
        
    }];
    
}

// Delete manual drug from db
- (IBAction)deleteManualDrug:(id)sender {
    
    NSDictionary *drugInfo = self.medicinesListArray[([sender tag] - AlarmButtonTagOffset)];
    [self.medicinesListArray removeObject:drugInfo];
    self.deleteManualDrugOptionViewConstraint.constant = 0;
    deleteOptionsView.hidden = YES;
    deleteOptionsView.alpha = 0.0;
    
    [AlertHandler removeNotificationForManualDrug:drugInfo[@"drugName"]];
    [medicinesTableView reloadData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *drugArray = [defaults objectForKey:[self loggedInUserKey]] ? [NSMutableArray arrayWithArray:[defaults objectForKey:[self loggedInUserKey]]] : [NSMutableArray array];
    if (drugArray) {
        [drugArray removeObject:drugInfo];
    }
    [defaults setObject:drugArray forKey:[self loggedInUserKey]];
    [defaults synchronize];
}

// Delete drug
- (void)deleteDrug:(int)drugIndex {
    
    [deleteDrugButton setTag:(drugIndex + AlarmButtonTagOffset)];
    [self showDeleteOptionsView];
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

#pragma mark
#pragma mark MultisourceDataDelegate

- (void)successFullyFetchedMultiSourceSavingsData:(NSArray *)data withClaimHistory:(Claims *)claim {
    
    if ([data count] > 0) {
        DDXMLElement *drugElement = data[0];
        NSString *ndc = [EHHelpers xmlElementValueForKey:@"INGREDIENT" forXmlElement:drugElement];
        if ([ndc boolValue] > 0) {
            claim.drug.multisource = @"O";
        }
        else {
            claim.drug.multisource = @"Y";
        }
        [[APP_DELEGATE managedObjectContext] save:nil];
        
    }
    [medicinesTableView reloadData];
    
}

#pragma mark
#pragma mark Show Savings Screen

- (void)showMySaving:(id)sender {
    
    UIButton *saveButton = (UIButton*)sender;
    self.selectedMedicine = self.medicinesListArray[saveButton.tag];
    [EHHelpers registerGAWithCategory:@"Medicine Cabinet Likely Savings" forAction:@"Show Likely Savings"];
    [self performSegueWithIdentifier:@"showDrugSaving" sender:nil];
}


#pragma mark
#pragma mark Show Refill Screen

- (void)drugRenewalRefill:(int)drugIndex {
    
    self.selectedMedicine = self.medicinesListArray[drugIndex];
    [EHHelpers registerGAWithCategory:@"Medicine Cabinet Refill" forAction:@"Show Refill"];
    [self performSegueWithIdentifier:@"showRenewRefill" sender:nil];
}

#pragma mark
#pragma mark Show Settings Screen

- (IBAction)showProfileSettings:(id)sender {
    
    SettingsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark 
#pragma mark Show Alarm List Screen

- (void)showAlarmsForDrugIndex:(int)drugIndex {
    
    self.selectedMedicine = self.medicinesListArray[drugIndex];
    
    [self performSegueWithIdentifier:@"showDrugAlarms" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDrugAlarms"]) {
        
        AlarmListViewController *vc = [segue destinationViewController];
        vc.drugInfo= self.selectedMedicine;
    }
    else if ([[segue identifier] isEqualToString:@"showDrugSaving"]){
        
        DrugSavingsViewController *vc = [segue destinationViewController];
        vc.drugInfo= self.selectedMedicine;
    }
    else if ([[segue identifier] isEqualToString:@"showRenewRefill"]) {
        RenewRefillViewController *rVC = [segue destinationViewController];
        rVC.drugInfo= self.selectedMedicine;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Side Menu

- (IBAction)showMenu {
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}


#pragma mark
#pragma mark Manual Drug Adding TextView
// Show add drug search view
- (IBAction)showHideSearch {
    
    drugAddField.text =@"";
    [drugAddField resignFirstResponder];
    [addDrugButton setSelected:!addDrugButton.isSelected];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.addDrugHeightConstraint.constant = (addDrugButton.isSelected == YES)? ADD_DRUG_CONTAINER_HEIGHT : 0;
        [searchView updateConstraints];
        [hideKeyBoardButton removeFromSuperview];        [self.view layoutIfNeeded];
        
    } completion:nil];

    
}

// Add drug To db
- (IBAction)addDrug {
    
    NSString *drugName = [[drugAddField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    drugAddField.text = @"";
    if ([drugName length] == 0) {
        //Removed alert as per request. Will add later if client wants it
        return;
    }
    [self showHideSearch];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *drugArray = [defaults objectForKey:[self loggedInUserKey]] ? [NSMutableArray arrayWithArray:[defaults objectForKey:[self loggedInUserKey]]] : [NSMutableArray array];
    NSPredicate *drugPredicate = [NSPredicate predicateWithFormat:@"drugName == %@",drugName];
    
    NSArray *multipleDrugArray = [drugArray filteredArrayUsingPredicate:drugPredicate];
    if ([multipleDrugArray count] > 0 ) {
        NSString *message = [NSString stringWithFormat:@"%@ already exists.",drugName];
        [EHHelpers showAlertWithTitle:@"" message:message delegate:nil];
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    //Optionally for time zone converstions
    NSDictionary *drugInfo = [NSDictionary dictionaryWithObjectsAndKeys:drugName,@"drugName",nil];
    
    [drugArray insertObject:drugInfo atIndex:0];
    [defaults setObject:drugArray forKey:[self loggedInUserKey]];
    [defaults synchronize];
    
    [self addManualDrugs];
    [medicinesTableView reloadData];
    
}

- (NSString*)loggedInUserKey {
    
    NSString *userLoggedInKey = kUserDefinedDrugs;
    User *currentUser = [APP_DELEGATE currentUser];
    if (currentUser != nil) {
        userLoggedInKey = [NSString stringWithFormat:@"%@-%@",userLoggedInKey,currentUser.memberId];
    }
    return userLoggedInKey;
}
- (IBAction)scrollMedListToTop:(id)sender {
    
    [medicinesTableView setScrollsToTop:YES];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSString*)drugName:(id)drugObj {
    
    NSString *drugName = @"";
    if ([drugObj isKindOfClass:[Claims class]]) {
        Claims *claimObj = (Claims *)drugObj;
        drugName = claimObj.drug.proddescabbrev;
    }
    else {
        drugName = drugObj[@"drugName"];
    }
    return drugName;
}

- (void)updateAlertsForDrug {
    
    User *currentuser = [APP_DELEGATE currentUser];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    for (id  drug in self.medicinesListArray) {
        
        NSString *drugName  = [self drugName:drug];
        NSString *alertCacheKey =  [NSString stringWithFormat:@"%@_%@_%@",kUserAlerts,currentuser.email,drugName];;
        NSArray *alarms = [NSArray array];
        alarms = [userDefaults objectForKey:alertCacheKey];
        NSArray *newAlerts = [AlertHandler updateStatusForAlerts:alarms];
        [userDefaults setObject:[NSArray arrayWithArray:newAlerts] forKey:alertCacheKey];
    }
    [userDefaults synchronize];
}


// Update the status of the alert if the repeat interval is never and the time has expired


@end
