//
//  PharmacyDetailViewController.m
//  EngageHealth
//
//  Created by Nassif on 18/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "PharmacyDetailViewController.h"

@interface PharmacyDetailViewController ()

@end

@implementation PharmacyDetailViewController
@synthesize pharmacyDetail;

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
    self.screenName = @"Pharmacy Info";
    popUpView.hidden= YES;
    [self updatePharmacyView];
    [self displayMap];
    
    // Do any additional setup after loading the view.
}

- (void)updatePharmacyView {
    
    float origin = 0;
    distanceLabel.text = @"";

    if (self.showDrugInfo) {
        
        drugNameLabel.text = self.pharmacyDetail[@"PRODDESCABBREV"];
        drugSupplyDaysLabel.text = [NSString stringWithFormat:@"Pay $%0.2f for %d day supply",[self.pharmacyDetail[@"Copay"] floatValue],[self.pharmacyDetail[@"orderType"] intValue] != 0 ? self.claimsInfo.daysSupply.intValue : 90];
        
        drugSaveAmountLabel.text = [NSString stringWithFormat:@"$%@",self.pharmacyDetail[@"save"]];
        
        drugSaveAmountLabel.backgroundColor  = [self.pharmacyDetail[@"save"] floatValue] < 0.0 ? Saving_Red :GREEN_COLOR;
        drugSaveAmountLabel.attributedText = [self attributedTextForPricingText:[NSString stringWithFormat:@"%0.2f",[self.pharmacyDetail[@"save"] floatValue]] ];

        [drugInfoView layoutIfNeeded];

        origin = [drugInfoView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    distanceLabel.text = self.isFromRefill == YES ? @"": [NSString stringWithFormat:@"%0.2f Miles",[self.pharmacyDetail[@"distance"] floatValue]];
    self.scrollViewOriginConstraint.constant = origin;
    
    if ([self pharmacyHasOperationHours] == NO) {
        self.mapHeightConstraint.constant = 220;
        self.operationHoursHeightConstraint.constant = 0;
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:operationHrsView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0f
                                                                             constant:0];
        [operationHrsView addConstraint:heightConstraint];
        
    }
    self.vaccineOriginConstraint.constant = [self.pharmacyDetail[@"retail"] boolValue] == true ? 68 : 5;
    
    [self.view updateConstraints];
    [drugInfoView updateConstraints];
    nameLabel.text = self.pharmacyDetail[@"name"];
    addressLabel.text = [self pharmaAddressDetails:pharmacyDetail forKeys:@[@"pAddress",@"sAddress",@"city",@"state",@"zip"]];
    phoneLabel.text = [NSString stringWithFormat:@"Phone: %@", [EHHelpers formatToPhoneNumber:self.pharmacyDetail[@"phone"]]];
    hoursLabel.text = self.pharmacyDetail[@"monHrs"] != nil && [self.pharmacyDetail[@"monHrs"] length] > 0 ? [self operationalHoursOfPharmacy:self.pharmacyDetail] : @"N-A";
    vaccineButton.hidden = [self.pharmacyDetail[@"vaccNetwork"] boolValue] == true ? NO : YES;
    retailerSupplyButton.hidden = [self.pharmacyDetail[@"retail"] boolValue] == true ? NO : YES;
    navTitleLabel.text = nameLabel.text;
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
                      value:[UIFont fontWithName:APPLICATION_FONT_BOLD size:18]
                      range:NSMakeRange(subTextRange.location, subTextRange.length)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:APPLICATION_FONT_NORMAL size:14]
                      range:NSMakeRange(subTextRange.location + subTextRange.length, stringLength - (subTextRange.location + subTextRange.length) )];
    
    [attString addAttribute:NSForegroundColorAttributeName value: Saving_White range:NSMakeRange(0, stringLength)];
    return attString;
    
}

#pragma mark
// Operation Hours of a pharmacy
- (NSString*)operationalHoursOfPharmacy:(NSDictionary*)pharmacy {
    
    NSString *operationHrs = [NSString stringWithFormat:@"Mon - %@\nTue - %@\nWed - %@\nThu - %@\nFri - %@\nSat - %@\nSun - %@",pharmacyDetail[@"monHrs"],pharmacyDetail[@"tueHrs"],pharmacyDetail[@"wedHrs"],pharmacyDetail[@"thuHrs"],pharmacyDetail[@"friHrs"],pharmacyDetail[@"satHrs"],pharmacyDetail[@"sunHrs"]];
    return operationHrs;
}

#pragma mark
// Check if the pharmacy has operation hour details
- (BOOL)pharmacyHasOperationHours {
    
    NSArray *hours = @[@"monHrs",@"tueHrs",@"wedHrs",@"thuHrs",@"friHrs",@"satHrs",@"sunHrs"];
    NSMutableArray *opnHrs = [NSMutableArray array];
    
    for (NSString *hourKey in  hours) {
        
        NSString *operationHour = self.pharmacyDetail[hourKey];
        if ([operationHour rangeOfString:@"N/A"].location == NSNotFound) {
            [opnHrs addObject:@"1"];
        }
    }
    return [opnHrs count] > 0 ? YES : NO;
}

#pragma mark
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
#pragma mark Display Map

// Display Map and add annotations
- (void)displayMap {
    NSMutableArray *venueAnnotations = [NSMutableArray array];
    
    VenueAnnotation *ann = [[VenueAnnotation alloc]init];
    
    ann.title = pharmacyDetail[@"name"];
    location.latitude =[pharmacyDetail[@"lat"] floatValue];
    location.longitude = [pharmacyDetail[@"lon"] floatValue];
    
    ann.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    [pharmaMapView addAnnotation:ann];
    [venueAnnotations addObject:ann];
    
    [self zoomToRegionWithAnnotation:[venueAnnotations objectAtIndex:0]];
    [pharmaMapView selectAnnotation:[venueAnnotations objectAtIndex:0] animated:YES];
    
}

- (void)zoomToRegionWithAnnotation:(VenueAnnotation *)annotation {
    
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    MKCoordinateRegion region;
    
    region.span = span;
    region.center = annotation.coordinate;
    
    if(pharmaMapView != nil) {
        [pharmaMapView setRegion:region animated:TRUE];
        [pharmaMapView regionThatFits:region];
    }
}

#pragma mark
#pragma mark _ MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] ;
    }
    
    annotationView.image = [UIImage imageNamed:@"map_pin"];
    annotationView.annotation = annotation;
    // annotationView.canShowCallout = YES;
    
    return annotationView;
}

#pragma mark 
#pragma mark Call Pharmacy

// Call the pharmacy
- (IBAction)makeCall:(id)sender {
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@", pharmacyDetail[@"phone"]];
    NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneStr]];
    [[UIApplication sharedApplication] openURL:url];
    
}

#pragma mark
#pragma mark Directions

// Get Direction : Opens the google maps app ,if installed. else open default browser
- (IBAction)getDirection:(id)sender {

    
    if (![EHHelpers isLocationServiceActive]) {
        [EHHelpers showAlertWithTitle:@"" message:@"Please enable the location service to get your directions" delegate:nil];
    }
    else{
    CLLocation *userLocation = [EHLocationService sharedInstance].currentLocation;

    NSString *userLat = [NSString stringWithFormat:@"%f",userLocation.coordinate.latitude];
    NSString *userLong = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
    
    
    NSString *dirUrl = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@,%@&daddr=%f,%f", userLat, userLong, [pharmacyDetail[@"lat"] floatValue], [pharmacyDetail[@"lon"] floatValue]];
    
    
    NSString *googleAppDirection = [NSString stringWithFormat:@"comgooglemaps://?saddr=%@,%@&daddr=%f,%f&directionsmode=driving&zoom=10",userLat,userLong,[pharmacyDetail[@"lat"] floatValue], [pharmacyDetail[@"lon"] floatValue]];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:googleAppDirection]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleAppDirection]];
    }                                                                                                                                                                                                                 else if ([EHHelpers canUseMKMapItem]) {
        [self showTheIosMap];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dirUrl]];
    }
    }
}

#pragma mark Ios 6 Map

- (void)showTheIosMap {
    
    CLLocation *userLocation = [EHLocationService sharedInstance].currentLocation;
    NSString *userLat = [NSString stringWithFormat:@"%f",userLocation.coordinate.latitude];
    NSString *userLong = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
    
    
    // Get the placemark for the present location
    CLLocationCoordinate2D coordinate =
    CLLocationCoordinate2DMake([userLat doubleValue], [userLong doubleValue]);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:@"My Place"];
    
    CLLocationCoordinate2D destinationCoordinate =      CLLocationCoordinate2DMake([pharmacyDetail[@"lat"] doubleValue], [pharmacyDetail[@"lon"] doubleValue]);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoordinate
                                                              addressDictionary:nil];
    MKMapItem *currentLocationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [currentLocationMapItem setName:pharmacyDetail[@"name"]];
    
    NSArray *array = [NSArray arrayWithObjects:mapItem,currentLocationMapItem, nil];
    
    [MKMapItem openMapsWithItems:array
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, nil]];
    
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark
#pragma mark Custom PopUp (Vaccine/Retailer)
// Hide the Custom Pop Up Alerts
- (IBAction)hidePopUpView:(id)sender {
    
    popUpView.hidden = YES;
    vaccinePopUpView.hidden = YES;
    supplyPopUpView.hidden = YES;
}

// Show vaccine alert
- (IBAction)showVaccineAlert:(id)sender {
    
    popUpView.hidden = NO;
    vaccinePopUpView.hidden = NO;
    supplyPopUpView.hidden = YES;
    
}

// Shows the retailer's day supply alert
- (IBAction)showDaySupplyAlert:(id)sender {
    
    popUpView.hidden = NO;
    vaccinePopUpView.hidden = YES;
    supplyPopUpView.hidden = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
