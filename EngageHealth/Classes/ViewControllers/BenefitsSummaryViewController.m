//
//  BenefitsSummaryViewController.m
//  EngageHealth
//
//  Created by Nassif on 04/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "BenefitsSummaryViewController.h"

@interface BenefitsSummaryViewController ()

@end

@implementation BenefitsSummaryViewController

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
    
    self.screenName = @"Benefits Summary";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutUser) name:@"Benefits_Logout" object:nil];
    htmlPageView.contentType = BenefitsSummary;
    [htmlPageView loadHTMLData];
    // Do any additional setup after loading the view.
}


#pragma mark -
#pragma mark IBActionMethods

- (IBAction)showMenu {
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}

- (void)logOutUser {
    
    [APP_DELEGATE setCurrentUser:nil];
    [APP_DELEGATE stopSessionTimer];
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC.leftMenu performSegueWithIdentifier:@"showMedicineCabinetSegue" sender:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
