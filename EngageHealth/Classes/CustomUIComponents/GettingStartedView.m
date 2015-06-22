//
//  GettingStartedView.m
//  Envisionrx
//
//  Created by Nassif on 21/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "GettingStartedView.h"

@implementation GettingStartedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GettingStartedView" owner:nil options:nil];
        self = [nib objectAtIndex:0];
        [self setFrame:frame];
    }
    self.frame = frame;
    return self;
}


- (void)loadHtml {
   
    htmlWebView.scrollView.scrollEnabled = NO;
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"GettingStarted" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [htmlWebView loadHTMLString:htmlString baseURL:nil];
}

- (IBAction)start:(id)sender {
    
    [self.delegate getStarted];
}
@end
