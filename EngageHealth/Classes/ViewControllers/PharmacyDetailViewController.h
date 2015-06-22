//
//  PharmacyDetailViewController.h
//  EngageHealth
//
//  Created by Nassif on 18/08/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VenueAnnotation.h"
#import "AppDelegate.h"
#import "EHHelpers.h"
#import "Constants.h"
#import "Claims.h"
#import "GAITrackedViewController.h"


@interface PharmacyDetailViewController : GAITrackedViewController {
    
    
    IBOutlet UIView *drugInfoView;
    IBOutlet UILabel *drugNameLabel,*drugSupplyDaysLabel,*drugSaveAmountLabel;
    
    
    IBOutlet UILabel *nameLabel,*addressLabel,*cityLabel,*phoneLabel,*distanceLabel,*hoursLabel;
    IBOutlet UILabel *navTitleLabel;
    IBOutlet MKMapView *pharmaMapView;
    
    IBOutlet UIView *operationHrsView;
    IBOutlet UIButton *retailerSupplyButton,*vaccineButton;
    IBOutlet UILabel * hrsLabel;
    CLLocationCoordinate2D location;
    
    IBOutlet UIView *popUpView,*vaccinePopUpView,*supplyPopUpView;
    
}

@property BOOL showDrugInfo;
@property (nonatomic ,strong) NSDictionary *pharmacyDetail;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *scrollViewOriginConstraint ,*operationHoursHeightConstraint,*mapHeightConstraint,*vaccineOriginConstraint;
@property (nonatomic ,strong) Claims *claimsInfo;
@property  BOOL isFromRefill;

- (IBAction)makeCall:(id)sender;
- (IBAction)getDirection:(id)sender;
- (IBAction)back:(id)sender;

- (IBAction)showVaccineAlert:(id)sender;
- (IBAction)hidePopUpView:(id)sender;

- (IBAction)showDaySupplyAlert:(id)sender;
@end
