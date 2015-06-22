//
//  GettingStartedView.h
//  Envisionrx
//
//  Created by Nassif on 21/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GettingStartedDelegate <NSObject>

- (void)getStarted;

@end

@interface GettingStartedView : UIView
{
    IBOutlet UIWebView *htmlWebView;
}

@property (nonatomic ,strong) id<GettingStartedDelegate>delegate;
- (void)loadHtml;
- (IBAction)start:(id)sender;

@end
