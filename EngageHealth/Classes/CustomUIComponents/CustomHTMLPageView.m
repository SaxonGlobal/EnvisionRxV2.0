//
//  CustomHTMLPageView.m
//  Envisionrx
//
//  Created by Nassif on 10/10/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "CustomHTMLPageView.h"

@implementation CustomHTMLPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomHTMLPageView" owner:nil options:nil];
        self = [nib objectAtIndex:0];
        [self setFrame:frame];
    }
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    
    [self initialiseLoadingView];
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [self initialiseLoadingView];
    
    
    return self;
}
// Initialise the custom loading view
- (void)initialiseLoadingView {
    customLoadingView = [[LoadingView alloc] init];
    customLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
}

// Initialise the custom Attributed view
- (void)initialiseAttributedView {
    
    htmlAttributedTextView = [[DTAttributedTextView alloc] init];
    htmlAttributedTextView.translatesAutoresizingMaskIntoConstraints = NO;
    htmlAttributedTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:htmlAttributedTextView];
    NSDictionary *views = NSDictionaryOfVariableBindings(htmlAttributedTextView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[htmlAttributedTextView]|" options:0  metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[htmlAttributedTextView]|" options:0  metrics:nil views:views]];
    [self updateConstraints];
    
}
// Show loading screen
- (void)showLoadingView {
    
    [self addSubview:customLoadingView];
    NSDictionary *views = NSDictionaryOfVariableBindings(customLoadingView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customLoadingView]|" options:0  metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[customLoadingView]|" options:0  metrics:nil views:views]];
    [self updateConstraints];
    [self layoutIfNeeded];
    [self loadData];
    
}

// Cancel animation
- (void)cancel {
    
    [customLoadingView clearAllAnimations];
    [customLoadingView removeFromSuperview];
    [htmlAttributedTextView removeFromSuperview];
    
}

// Load Data with animation
- (void)loadHTMLData {
    [self showLoadingView];
}

// Load Data
- (void)loadData {
    [self loadDataWithType:self.contentType];
}

// File Name for content type
- (NSString*)fileNameForContentType:(int)type {
    return type == BenefitsSummary ? BenefitsDataFile :Terms_Condition;
}

// Load the data for content type
- (void)loadDataWithType:(int)dataType {
    
    [customLoadingView startAnimations];
    
    if ([EHHelpers fileExistsAtDocDir:[self fileNameForContentType:self.contentType]]) {
        
        [self cancel];
        [self loadLocalDataForContentType];
    }
    else {
        if ([EHHelpers isNetworkAvailable]) {
            if (self.contentType == TermsAndCondition) {
                [self loadTermsAndCondition];
                
                NSString *dateString = [[NSUserDefaults standardUserDefaults] objectForKey:kPlanUpdateDate];
                if ([dateString length] > 0) {
                    NSDate *planDate = [EHHelpers dateFromString:dateString];
                    if (planDate && [[NSDate date] timeIntervalSinceDate:planDate] > (DAY_IN_SECONDS)) {
                        [self fetchPlanOverView];
                    }
                }
            }
            else{
                [self fetchPlanOverView];
            }
        }
        else{
            [self cancel];
            [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
        }
    }
}


- (void)loadLocalDataForContentType {
    
    if (self.contentType == BenefitsSummary) {
        NSString *benefitsSummary =  [[NSString alloc] initWithData:[EHHelpers dataFromFile:BenefitsDataFile]
                                                           encoding:NSUTF8StringEncoding];
        [self updateHTMLViewWithData:benefitsSummary];
        
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowContinue" object:nil];
        NSDictionary *summary = [EHHelpers arrayFromFile:[self fileNameForContentType:self.contentType]][0];
        NSString *summarytext = summary[@"content"];
        [self updateHTMLViewWithData:summarytext];
        
    }
}




#pragma mark TermsAndConditions (API/RESPONSE)
- (void)loadTermsAndCondition {
    
    NSString *soapAction = [NSString stringWithFormat:@"%@/GetTermsAndConditions", API_ACTION_ROOT];
    NSString *soapBodyXML = [NSString stringWithFormat:EHTermsAndConditions] ;
    
    NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
    [self.networkOperation loadTermsAndConditionsWithBody:soapBody forAction:soapAction];

}

- (void)successfullyLoadedTermsAndConditions:(NSArray *)data {
    
    [self cancel];
    if ([data count] > 0) {
        [self cacheDataForType:TermsAndCondition withContents:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowContinue" object:nil];
    }
}

#pragma mark
#pragma mark PlanOverView (API/RESPONSE)

- (void)fetchPlanOverView {
    
    User *currentuser = [APP_DELEGATE currentUser];
    
    if (currentuser) {
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetPlanOverview", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHPlanOverView, currentuser.email, currentuser.guid,AppID] ;
        
        NSString *soapBody = [NSString stringWithFormat:SOAP_BODY_XML,  soapBodyXML];
        [self.networkOperation fetchPlanOverviewWithBody:soapBody forAction:soapAction];
        
    }
}

- (void)successFullyReceivedPlanOverView:(NSArray *)data {
    [self cancel];
    if ([data count] > 0) {
        NSData* planDATA=[[data[0] stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        [EHHelpers writeData:planDATA toFile:BenefitsDataFile];
        [self updateHTMLViewWithData:[data[0] stringValue]];
        [[NSUserDefaults  standardUserDefaults] setObject:[EHHelpers stringFromDate:[NSDate date] format:kDefaultDateFormat] forKey:kPlanUpdateDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

#pragma mark 
#pragma mark API Error Handler

- (void)error:(NSError *)operationError {
    
    [self cancel];
    
    if ([[operationError localizedDescription] isEqualToString:@"The Internet connection appears to be offline."]) {
        [EHHelpers showAlertWithTitle:@"" message:@"Unable to connect to the network." delegate:nil];
    }
    else{
        NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
        if ([errorMessage length] > 0) {
            [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
            if (self.contentType ==  BenefitsSummary && [errorMessage isEqualToString:@"Invalid GUID. Please log in again"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Benefits_Logout" object:nil];
            }
        }
        
    }
    
}

// Update the html page with data summary
- (void)updateHTMLViewWithData:(NSString*)summary {
    summary = [summary stringByReplacingOccurrencesOfString:@"#6486AE" withString:@"#33607E"];
    [self initialiseAttributedView];
    htmlAttributedTextView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    htmlAttributedTextView.attributedString = [EHHelpers attributedStringWithString:summary size:16.0];
    htmlAttributedTextView.scrollEnabled = YES;
    [htmlAttributedTextView reloadInputViews];
    
}

#pragma mark 
#pragma mark Cache Data 

// Cache data based on the content type (Terms Data && Benefits)
- (void)cacheDataForType:(int)dataType withContents:(NSArray*)contentData{
    
    if ([contentData count] > 0) {
        [self updateHTMLViewWithData:[contentData[0] stringValue]];
        NSDictionary *contentDict = [NSDictionary dictionaryWithObject:[contentData[0] stringValue] forKey:@"content"];
        [EHHelpers writeArrayToPlist:Terms_Condition array:[NSArray arrayWithObject:contentDict]];
    }
}
@end
