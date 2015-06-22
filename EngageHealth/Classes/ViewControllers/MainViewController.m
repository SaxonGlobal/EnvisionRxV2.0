//
//  MainViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 7/24/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

enum {
    showMedicineCabinet,
    showFindCare,
    showMyIDCard,
    showBenefitsSummary,
    showFAQ,
    showSettings,
    logoutUser
};

@implementation MainViewController

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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case showMedicineCabinet:
            return @"showMedicineCabinetSegue";
            break;
        case showMyIDCard:
            return @"showIdCardSegue";
            break;
        case showFindCare:
            return @"showFindCareSegue";
            break;
            
            case showFAQ:
            return @"showFAQSegue";
            break;
        case showSettings:
            return @"showSettingsSegue";
            break;
            
            case showBenefitsSummary:
            return @"showBenefitsSummarySegue";
            break;
            
        case logoutUser:
        {
            [APP_DELEGATE setCurrentUser:nil];
            [APP_DELEGATE stopSessionTimer];
        }
            return @"showMedicineCabinetSegue";
            break;
        default:
            break;
    }
    return @"showMedicineCabinetSegue";
}

- (void)openLeftMenu{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenLeftMenuNotification" object:nil];
    [self openLeftMenuAnimated:YES];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
