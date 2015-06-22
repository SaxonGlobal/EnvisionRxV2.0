//
//  MenuCell.h
//  Envisionrx
//
//  Created by Nassif on 29/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell

@property (nonatomic , weak) IBOutlet UIButton *menuButton;
@property (nonatomic , weak) IBOutlet UILabel *menuLabel;
@property (nonatomic , weak) IBOutlet UIImageView *menuIcon;

@end
