//
//  BenefitsSummaryViewController.h
//  EngageHealth
//
//  Created by Nassif on 04/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCoreText.h"
#import "User.h"
#import "UIViewController+AMSlideMenu.h"
#import "CustomHTMLPageView.h"
#import "Constants.h"
#import "GAITrackedViewController.h"


@interface BenefitsSummaryViewController : GAITrackedViewController {
    
    IBOutlet CustomHTMLPageView *htmlPageView;
}

- (IBAction)showMenu;
@end
