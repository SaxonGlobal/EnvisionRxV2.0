//
//  FaqTableCell.h
//  EngageHealth
//
//  Created by Nassif on 12/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCoreText.h"

@interface FaqTableCell : UITableViewCell


@property (nonatomic ,strong) IBOutlet DTAttributedTextView *answerTextView;
@end
