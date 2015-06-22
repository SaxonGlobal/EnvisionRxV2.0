//
//  FrequentlyAskedQuestionViewController.h
//  EngageHealth
//
//  Created by Nassif on 12/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+AMSlideMenu.h"
#import "DTCoreText.h"
#import "FaqTableCell.h"
#import "NoDrugView.h"
#import "MenuOptionsViewController.h"
#import "EHOperation.h"
#import "Constants.h"
#import "LoadingView.h"
#import "GAITrackedViewController.h"


@interface FrequentlyAskedQuestionViewController : GAITrackedViewController <UITableViewDataSource,UITableViewDelegate,EHOperationProtocol> {

    IBOutlet  UITableView *faqTableVIew;
    
}

@property (nonatomic ,strong) NSLayoutConstraint *topConstraint;
@property (nonatomic ,strong) NSArray *faqListArray;
@property int selectedIndex;
@property (nonatomic ,strong) EHOperation *networkOperation;


- (IBAction)showMenu;
@end
