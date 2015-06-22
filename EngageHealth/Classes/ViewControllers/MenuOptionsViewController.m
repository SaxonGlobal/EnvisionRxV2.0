//
//  MenuOptionsViewController.m
//  EngageHealth
//
//  Created by Nithin Nizam on 7/24/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "MenuOptionsViewController.h"

@interface MenuOptionsViewController ()

@end

@implementation MenuOptionsViewController

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
    float colorValue = 235.0/255.0f;
    self.view.backgroundColor = [UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0];
    self.tableView.scrollEnabled = NO;
    
    self.menuOptionsArray = @[@"Medicine Cabinet", @"Find Pharmacy", @"MY ID CARD", @"Benefits Summary", @"Faq", @"My Profile", @"Logout"];
    self.menuImagesArray = @[@"medicine_cabinet_logo", @"find_care_logo", @"my_drug_card_logo", @"benefits_logo", @"faq_logo", @"settings_logo", @"logout"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.selectedIndexPath =  (self.selectedIndexPath < self.menuOptionsArray.count - 1) ? self.selectedIndexPath : 0;
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)imageNameForMenu:(NSInteger)index isSelected:(BOOL)shouldHighlight {
    
    NSString *imageName = self.menuImagesArray[index];
    
    if (shouldHighlight == YES) {
        imageName =   [NSString stringWithFormat:@"%@_selected",imageName];
    }
    
    return imageName;
    
    
}
#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IS_IPHONE_5 ? 60 : 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuOptionsArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    float colorValue = 235.0/255.0f;
    headerView.backgroundColor = [UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0];
    UIImageView *headerLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_header"]];
    CGRect headerRect = headerLogo.frame;
    headerRect.origin.x = 0;
    headerRect.origin.y = 10;
    [headerLogo setFrame:headerRect];
    [headerView addSubview:headerLogo];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MenuCell *menuCell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:@"MenuCellIdentifier"];
    if (!menuCell) {
        menuCell = [[[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil] objectAtIndex:0];
    }
    
    menuCell.menuLabel.textColor = (indexPath.row == self.selectedIndexPath) ?[UIColor whiteColor] : [UIColor colorWithRed:78.0/255.0 green:78.0/255.0 blue:59.0/255.0 alpha:1.0];
    menuCell.menuLabel.text = [self.menuOptionsArray[indexPath.row] uppercaseString];
    NSString *imageName= [self imageNameForMenu:indexPath.row isSelected:(self.selectedIndexPath == indexPath.row) ? YES : NO];
    menuCell.menuIcon.image = [UIImage imageNamed:imageName];
    menuCell.menuButton.tag = indexPath.row;
    [menuCell.menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    NSString *menuBg = (self.selectedIndexPath == indexPath.row )? @"menuorange" : @"menuwhite";
    [menuCell.menuButton setImage:[UIImage imageNamed:menuBg] forState:UIControlStateNormal];
    [menuCell.menuButton setImage:[UIImage imageNamed:menuBg] forState:UIControlStateSelected];
    
    return menuCell;
}


- (void)showMenu:(id)sender {
    
    UIButton *menuButton = (UIButton*)sender;
    
    self.selectedIndexPath  = (int)menuButton.tag;
    [self.tableView reloadData];
    NSString *segueIdentifier = [self.mainVC segueIdentifierForIndexPathInLeftMenu:[NSIndexPath indexPathForItem:self.selectedIndexPath inSection:0]];
    if (segueIdentifier && segueIdentifier.length > 0)
    {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = (int)indexPath.row;
    [tableView reloadData];
    NSString *segueIdentifier = [self.mainVC segueIdentifierForIndexPathInLeftMenu:indexPath];
    if (segueIdentifier && segueIdentifier.length > 0)
    {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
