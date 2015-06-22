//
//  MyCardViewController.h
//  EngageHealth
//
//  Created by Nassif on 03/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Constants.h"
#import "UIViewController+AMSlideMenu.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


enum {
    Member = 100,
    PharmacyNo = 101,
    Emergency = 102,
    Police = 103,
    PoisonControl = 104,
    SuicideControl = 105,
    DomesticAbuse = 106
}Calls;


#define PoisonControlHotline @"1-800-222-1222"
#define SuicideHotline @"1-800-273-8255"
#define DomesticAbuseHotline @"1-800-799-7233"
#define EmergencyHotline @"911"
#define PoliceHotline @"311"

@interface MyCardViewController : GAITrackedViewController {
    
    IBOutlet UILabel *memberIdLabel,*groupIdLabel,*pcnLabel,*binLabel,*dobLabel,*carrierLabel, *memberHelpText,*supportText;
    IBOutlet UIButton *memberHelpButton,*pharmacyHelpButton,*suicideHotLineButton,*poisonControlButton,* domesticAbuseButton;
    IBOutlet NSLayoutConstraint *supportOriginConstraint;
}


- (IBAction)showMenu;
- (IBAction)makeCall:(id)sender;
@end
