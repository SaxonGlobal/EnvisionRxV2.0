//
//  MenuOptionsViewController.h
//  EngageHealth
//
//  Created by Nithin Nizam on 7/24/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AMSlideMenuLeftTableViewController.h"
#import "MainViewController.h"
#import "MenuCell.h"

@interface MenuOptionsViewController : AMSlideMenuLeftTableViewController{
    
}


@property (nonatomic ,strong) MainViewController *mainMenu;

@property (nonatomic, strong) NSArray *menuOptionsArray;
@property (nonatomic, strong) NSArray *menuImagesArray;
@property int selectedIndexPath;

- (void)showMenu:(id)sender;
@end
