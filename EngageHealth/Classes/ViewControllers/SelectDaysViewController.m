//
//  SelectDaysViewController.m
//  AIDSinfo
//
//  Created by Jancy James on 5/14/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import "SelectDaysViewController.h"

@interface SelectDaysViewController ()

@end

@implementation SelectDaysViewController
@synthesize alertDays;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    self.daysArray = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    [daysListTableView reloadData];
    [daysListTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Clicking done before/after selecting days
- (IBAction)doneAction:(id)sender {
    [self.obj selectedDayUserData:self.alertDays];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : [self.daysArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    hView.backgroundColor = [UIColor clearColor];
    return hView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *menuCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DayCellIdentifier"];
    if (!menuCell) {
        menuCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DayCellIdentifier"];
    }
    
    menuCell.accessoryType = UITableViewCellAccessoryNone ;
    menuCell.textLabel.textColor = [UIColor blackColor];
    menuCell.textLabel.font = [UIFont fontWithName:APPLICATION_FONT_NORMAL size:17.0];

    if (indexPath.section == 0) {
        menuCell.textLabel.text = @"Everyday";
        if (self.alertDays.count == 7) {
            menuCell.accessoryType = UITableViewCellAccessoryCheckmark ;
        }
        return menuCell;
    }

    NSString *key = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row +1 ]];
    if (self.alertDays[key] != nil) {
        menuCell.accessoryType = UITableViewCellAccessoryCheckmark ;

    }

    menuCell.textLabel.text = [NSString stringWithFormat:@"Every %@",self.daysArray[indexPath.row]];
    return menuCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if ([self.alertDays count] == 7) {
            [self.alertDays removeAllObjects];
        }
        else {
        for (int i = 1; i <= 7; i++) {
            NSString *key = [NSString stringWithFormat:@"%d",i];
            self.alertDays[key] = @"1";
        }
        }
    }
    else {
        NSString *key = [NSString stringWithFormat:@"%d",(int)indexPath.row + 1];
        if (self.alertDays[key] != nil) {
            [self.alertDays removeObjectForKey:key];
            
        }
        else{
            self.alertDays[key] = @"1";
            
        }
    }
    [daysListTableView reloadData];
}







@end
