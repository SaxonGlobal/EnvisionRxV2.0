//
//  CustomHTMLPageView.h
//  Envisionrx
//
//  Created by Nassif on 10/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "DTCoreText.h"
#import "EHOperation.h"
#import "Constants.h"


enum {
    BenefitsSummary = 1001,
    TermsAndCondition = 1002
};
@interface CustomHTMLPageView : UIView <EHOperationProtocol>{
    
    LoadingView *customLoadingView;
    DTAttributedTextView *htmlAttributedTextView;
    
}

@property int contentType;

@property (nonatomic ,strong) EHOperation *networkOperation;
- (void)loadDataWithType:(int)dataType;
- (void)cancel;

- (void)loadHTMLData;
@end
