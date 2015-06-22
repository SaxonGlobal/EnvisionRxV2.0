//
//  SelectDaysViewController.h
//  AIDSinfo
//
//  Created by Jancy James on 5/14/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@protocol SelectDaysDelegate
@required
- (void)selectedDayUserData:(NSMutableDictionary*)userData;

@end

@interface SelectDaysViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    
    IBOutlet UITableView *daysListTableView;
}
@property (nonatomic, retain) NSArray *daysArray;
@property (nonatomic, retain) NSMutableDictionary *alertDays;
@property (nonatomic ,assign) id<SelectDaysDelegate>obj;
@end
