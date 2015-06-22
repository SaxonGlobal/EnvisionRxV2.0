//
//  MyCardViewController.m
//  EngageHealth
//
//  Created by Nassif on 03/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MyCardViewController.h"

@interface MyCardViewController ()

@end

@implementation MyCardViewController

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
    self.screenName = @"My Card";
    [self updateMyCardView];
    // Do any additional setup after loading the view.
}

- (void)updateMyCardView {
    
    User *currentuser = [APP_DELEGATE currentUser];
    if (currentuser != nil) {
        memberIdLabel.text = [NSString stringWithFormat:@"%@", currentuser.memberId];
        groupIdLabel.text = [NSString stringWithFormat:@"%@", currentuser.groupId] ;
        pcnLabel.text = currentuser.pcn;
        binLabel.text = currentuser.bin;
        dobLabel.text = currentuser.dob;
        carrierLabel.text = currentuser.carrier;
        [EHHelpers underlineButtonText:memberHelpButton withString:currentuser.memberHelp];
        [EHHelpers underlineButtonText:pharmacyHelpButton withString:currentuser.pharmacyHelp];
        
        if ([currentuser.memberHelp isEqualToString:currentuser.pharmacyHelp]) {
            memberHelpText.hidden = YES;
            memberHelpButton.hidden = YES;
            supportOriginConstraint.constant = -2.0;
            supportText.text = @"Support:";
            
        }
    }
    [EHHelpers underlineButtonText:poisonControlButton withString:PoisonControlHotline];
    [EHHelpers underlineButtonText:domesticAbuseButton withString:DomesticAbuseHotline];
    [EHHelpers underlineButtonText:suicideHotLineButton withString:SuicideHotline];

}

#pragma mark -
#pragma mark IBActionMethods

- (IBAction)showMenu {
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)makeCall:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    NSString *phoneString = @"";
    
    
    switch (btn.tag) {
        case Member:
            phoneString = [memberHelpButton.titleLabel.text
                           stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [self registerGAWithActionString:@"Customer Service/ MemberHelp / PharmacyHelp" withCategory:@"Customer Service"];
            break;
            
        case PharmacyNo:
            phoneString = [pharmacyHelpButton.titleLabel.text
                           stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [self registerGAWithActionString:@"Customer Service/ MemberHelp / PharmacyHelp" withCategory:@"Customer Service"];

            break;
            
        case Emergency:
            phoneString = EmergencyHotline;
            [self registerGAWithActionString:@"Emergency" withCategory:@"Hotline"];
            break;
            
        case Police:
            phoneString = PoliceHotline;
            [self registerGAWithActionString:@"Police" withCategory:@"Hotline"];
            break;
            
        case PoisonControl:
            phoneString = PoisonControlHotline;
            [self registerGAWithActionString:@"Poison Control" withCategory:@"Hotline"];
            break;
            
        case SuicideControl:
            phoneString = SuicideHotline;
            [self registerGAWithActionString:@"Suicide Control" withCategory:@"Hotline"];
            break;
            
        case DomesticAbuse:
            phoneString = DomesticAbuseHotline;
            [self registerGAWithActionString:@"Domestic Abuse Control" withCategory:@"Hotline"];
            break;
            
        default:
            break;
    }
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@", phoneString];
    NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneStr]];
    [[UIApplication sharedApplication] openURL:url];
    
    
}

- (void)registerGAWithActionString:(NSString*)actionString withCategory:(NSString*)categoryString{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryString            // Event category (required)
                                                          action:actionString  // Event action (required)
                                                           label:nil              // Event label
                                                           value:nil] build]];

}
@end
