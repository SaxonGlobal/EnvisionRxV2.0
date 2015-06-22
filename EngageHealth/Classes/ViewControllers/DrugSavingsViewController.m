//
//  DrugSavingsViewController.m
//  EngageHealth
//
//  Created by Nassif on 26/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "DrugSavingsViewController.h"
#import "Claims.h"
#import "Drugs.h"

@interface DrugSavingsViewController ()

@end

@implementation DrugSavingsViewController

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
    
    self.screenName = @"Likely Savings Screen 1";
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    Claims *ehClaim = (Claims*)self.drugInfo;
    drugTitle.text = ehClaim.drug.proddescabbrev;
    self.requestedCall = [NSMutableArray array];
    [self initialiseLoadingView];
    [self loadAlternativeDrugs];
}


- (void)loadAlternativeDrugs {
    
    Claims *ehClaim = (Claims*)self.drugInfo;
    NSArray *alternatives = [ehClaim.alternateDrug allObjects];

    if ([alternatives count] == 0 ) {
        
        if ([EHHelpers isNetworkAvailable]) {
            [self populateSavingsData];
        }
        else{
            [EHHelpers showAlertWithTitle:@"" message:@"No network available." delegate:nil];
        }
    }
    else {
        
        self.drugs = [NSMutableArray arrayWithArray:alternatives];
        [self sortSavings];
        NSPredicate *statusPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"status.intValue == %d",0]];
        NSArray *filteredStatusArray = [alternatives filteredArrayUsingPredicate:statusPredicate];
        if ([filteredStatusArray count] > 0 && ![EHHelpers isNetworkAvailable]) {
            [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.networkOperation cancelOp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Loading View
// Initialise the custom loading view
- (void)initialiseLoadingView {
    
    customLoadingView = [[LoadingView alloc] init];
    customLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
    
}

// Show loading screen
- (void)showLoadingView {
    
    [self.view addSubview:customLoadingView];
    NSDictionary *views = NSDictionaryOfVariableBindings(customLoadingView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customLoadingView]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[customLoadingView]|" options:0  metrics:nil views:views]];
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    [customLoadingView startAnimations];
    
}

#pragma mark
#pragma mark FetchAlternatives
// API call for loading medicine data for user
- (void)populateSavingsData {
    
    Claims *ehClaim = (Claims*)self.drugInfo;
    
    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser) {
        [self showLoadingView];
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetDrugByGPI", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHSavingsDrugByGPI, currentuser.email,currentuser.guid ,ehClaim.drug.gpi, AppID] ;
        
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
        [self.networkOperation fetchAlternativeDrugWithBody:soapBody forAction:soapAction];
        
    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again." delegate:nil];
        [self logOutUser];
    }
}

- (void)successFullyFetchedAlternativeDrug:(NSArray *)alternative {
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    [self populateSavingsDrug:alternative];
}

- (void)error:(NSError *)operationError {
    
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    
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
#pragma mark Populate the pricing data for the alternative drug
- (void)populateDrugSavingsPriceByNABP:(AlternateDrug*)drug {
    
    Claims *ehClaim = (Claims*)self.drugInfo;
    
    NSString *pharmacyId = ehClaim.pharmacyId;
    NSString *ndc = drug.ndc;
    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser && ![self.requestedCall containsObject:ndc] && drug.status.intValue == 0) {
        [self.requestedCall addObject:ndc];
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetDrugPricingByNABP", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHDrugPricingByNABP, currentuser.email,currentuser.guid ,ndc ,ehClaim.quantity.intValue,ehClaim.daysSupply.intValue,pharmacyId,AppID];
        
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
        [self.networkOperation fetchDrugPricingByNABPWithBody:soapBody forAction:soapAction withNDC:ndc];
    }
}


- (void)successFUllyReceivedPricingData:(NSArray *)pricingData withNDC:(NSString *)ndc{
    [self addSavingsDetails:pricingData withDrugNDC:ndc];
}

- (void)addSavingsDetails:(NSArray*)savings withDrugNDC:(NSString*)drugNDC{
    
    Claims *ehClaim = (Claims*)self.drugInfo;
    
    
    float drugPerYearPrice = ([ehClaim.memberPaid floatValue]/ehClaim.daysSupply.intValue ) *365;
    if ([savings count] > 0) {
        
        NSArray *drug = [savings [0] elementsForName:@"Drug"];
        
        NSArray *claimsPaymentDetails = [savings [0] elementsForName:@"RxClaims"];
        
        NSArray *priceDetails = [NSArray array];
        NSArray *drugdetails = [NSArray array];
        
        if ([claimsPaymentDetails count] > 0 ) {
            priceDetails =[claimsPaymentDetails [0] elementsForName:@"RxClaim"];
            
            if ([priceDetails count] > 0) {
                drugdetails = [priceDetails [0] elementsForName:@"DrugCost"];
                
            }
        }
        
        NSMutableDictionary *drugCostDetail = [NSMutableDictionary dictionary];
        
        for (DDXMLElement *cost in drugdetails) {
            drugCostDetail[@"Copay"] = [EHHelpers xmlElementValueForKey:@"Copay" forXmlElement:cost];
            drugCostDetail[@"PlanPay"] = [EHHelpers xmlElementValueForKey:@"PlanPay" forXmlElement:cost];
            
        }
        
        
        NSMutableDictionary *drugDict = [NSMutableDictionary dictionary];
        
        for (DDXMLElement *drugElement in drug) {
            drugDict[@"NDCUPCHRI"] = [EHHelpers xmlElementValueForKey:@"NDCUPCHRI" forXmlElement:drugElement];
            drugDict[@"PRODDESCABBREV"] =[EHHelpers xmlElementValueForKey:@"PRODDESCABBREV" forXmlElement:drugElement];
            drugDict[@"GPI"] =[EHHelpers xmlElementValueForKey:@"GPI" forXmlElement:drugElement];
            
        }
        
        NSString *pricingErrorMessage = @"THERE IS NO PRICING INFORMATION FOR THIS DRUG AT THIS TIME";
        
        if ([priceDetails count] > 0) {
            NSArray *message = [priceDetails [0] elementsForName:@"Response"];
            if ([message count] > 0) {
                NSArray *messageContent = [message [0] elementsForName:@"Status"];
                if ([messageContent count] > 0) {
                    if ([[messageContent[0] stringValue] isEqualToString:@"R"]) {
                        pricingErrorMessage = [[message [0] elementsForName:@"Message"][0] stringValue ];
                    }
                }
                
            }
        }
        
        NSArray *filteredArray = [self.drugs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ndc == %@)",drugNDC]];
        
        if (filteredArray.count !=0) {
            AlternateDrug *newDrugDetails = filteredArray[0];
            Claims *ehClaim = (Claims*)self.drugInfo;
            [ehClaim removeAlternateDrugObject:newDrugDetails];
            
            newDrugDetails.status = [NSNumber numberWithInteger:1];
            
            float priceSavings =  0;
            
            if ([drugCostDetail count] > 0 && [drugCostDetail[@"Copay"] length] > 0) {
                priceSavings =    ([drugCostDetail[@"Copay"] floatValue] / ehClaim.daysSupply.intValue )*365;
                newDrugDetails.savings = [NSNumber numberWithFloat:drugPerYearPrice - priceSavings];
                newDrugDetails.status = [NSNumber numberWithInteger:2];
                
            }
            newDrugDetails.errorMessage = pricingErrorMessage;
            [self.drugs removeObject:filteredArray[0]];
            [ehClaim addAlternateDrugObject:newDrugDetails];
            [[APP_DELEGATE managedObjectContext] save:nil];
            [self.drugs addObject:newDrugDetails];

        }
    }
    [self sortSavings];
}

- (void)sortSavings {
    
    NSSortDescriptor *priceSort = [[NSSortDescriptor alloc] initWithKey:@"savings.floatValue" ascending:NO];
    NSSortDescriptor *errorSort = [[NSSortDescriptor alloc] initWithKey:@"status.intValue" ascending:NO];

    NSArray *sortDescriptors = @[errorSort,priceSort];
    [self.drugs sortUsingDescriptors:sortDescriptors];
    [drugSavingsTableView reloadData];

}
- (void)populateSavingsDrug:(NSArray*)savingsDrugs {
    
    [self updateAlternateDrugDetailsToDB:savingsDrugs];
    Claims *ehClaims = (Claims*)self.drugInfo;
    self.drugs = [NSMutableArray arrayWithArray:[ehClaims.alternateDrug allObjects]];
    [drugSavingsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)updateAlternateDrugDetailsToDB:(NSArray*)alternatives{
    
    User *currentuser = [APP_DELEGATE currentUser];
    Claims *ehClaim = (Claims*)self.drugInfo;
    if (currentuser) {
        [Claims prepareAlternativeDrugData:alternatives forClaims:ehClaim];
    }
    
}
- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"drugSavingCell";
    
    DrugSavingCell *cell = (DrugSavingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DrugSavingCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    AlternateDrug *saveDrug = self.drugs[indexPath.row];
    cell.drugTitle.text = saveDrug.name;
    if (saveDrug.savings != nil) {
        
        cell.SavingsLabel.attributedText = [self attributedTextForPricingText:[NSString stringWithFormat:@"%0.2f",saveDrug.savings. floatValue] atIndex:(int)indexPath.row] ;
    }
    [cell layoutIfNeeded];
    __unused CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    float defaultHeight =  (indexPath.row == 0 ) ? 76 : 64;
    return fmaxf( height + 1,defaultHeight);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.drugs count];
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DrugSavingCell *cell = (DrugSavingCell *)[tableView dequeueReusableCellWithIdentifier:@"drugSavingCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DrugSavingCell" owner:self options:nil] objectAtIndex:0];
    }
    
    AlternateDrug *saveDrug = self.drugs[indexPath.row];
    
    cell.drugTitle.text = saveDrug.name;
    cell.savingContainerView.hidden = YES;
    cell.noPricingErrorLabel.hidden = YES;
    cell.detailedSavingsButton.tag = indexPath.row;
    cell.loadingLabel.text=@"Loading..";
    cell.userInteractionEnabled = NO;
  
    if (saveDrug.status.intValue != 0 || ![EHHelpers isNetworkAvailable]) {
        cell.loadingLabel.text=@"";

    }
    
    if (saveDrug.status.intValue  == 2) {
        
        cell.savingContainerView.hidden = NO;
        cell.SavingsLabel.attributedText = [self attributedTextForPricingText:[NSString stringWithFormat:@"%0.2f",saveDrug.savings. floatValue] atIndex:(int)indexPath.row] ;
        cell.userInteractionEnabled = YES;
        [cell.detailedSavingsButton addTarget:self action:@selector(showDetailedSavings:) forControlEvents:UIControlEventTouchUpInside];

        
    }
    if (saveDrug.status.intValue  == 1 && [saveDrug.errorMessage length] > 0) {
        cell.loadingLabel.hidden=YES;
        cell.noPricingErrorLabel.hidden = NO;
        cell.noPricingErrorLabel.text = saveDrug.errorMessage;
        
    }

    
    cell.savingContainerView.backgroundColor = (indexPath.row != 0 ) ?  Saving_White : (saveDrug.savings != nil && saveDrug.savings. floatValue < 0.0) ? Saving_Red : GREEN_COLOR;
    cell.rightArrow.image = (indexPath.row == 0) ? [UIImage imageNamed:@"med_rightarrow"] : [UIImage imageNamed:@"alarm_rightarrow"];
    [self populateDrugSavingsPriceByNABP:saveDrug];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSAttributedString*)attributedTextForPricingText:(NSString*)pricingValue atIndex:(int)subIndex {
    
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
                      value:[UIFont fontWithName:APPLICATION_FONT_BOLD size:18]
                      range:NSMakeRange(subTextRange.location, subTextRange.length)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange(subTextRange.location + subTextRange.length, stringLength - (subTextRange.location + subTextRange.length) )];
    
    [attString addAttribute:NSForegroundColorAttributeName value:(subIndex > 0 )? (saveValue < 0.0) ? Saving_Red : GREEN_COLOR : Saving_White range:NSMakeRange(0, stringLength)];
    return attString;
    
}
- (void)showDetailedSavings:(id)sender {
    
    UIButton *selectedButton = (UIButton*)sender;
    
    self.selectedDrug = self.drugs[selectedButton.tag];
    [EHHelpers registerGAWithCategory:@"Likely Savings - Alternative" forAction:self.selectedDrug.name];
    [self performSegueWithIdentifier:@"showDetailedSavings" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showDetailedSavings"]) {
        
        DetailedSavingsViewController *vc = [segue destinationViewController];
        vc.drugInfo= self.selectedDrug;
        vc.claimsInfo = self.drugInfo;
    }
    
}


@end
