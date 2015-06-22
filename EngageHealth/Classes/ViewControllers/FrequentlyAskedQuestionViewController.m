//
//  FrequentlyAskedQuestionViewController.m
//  EngageHealth
//
//  Created by Nassif on 12/09/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "FrequentlyAskedQuestionViewController.h"
#import "Faq.h"
#import "Faq+DAO.h"

@interface FrequentlyAskedQuestionViewController ()
@property (nonatomic ,strong) LoadingView *customloadingView;
@end

@implementation FrequentlyAskedQuestionViewController

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
    self.screenName = @"FAQ";
    
    self.selectedIndex = -1;
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [self initialiseLoadingView];
    [self fetchFAQ];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.networkOperation cancelOp];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark Loading Screen
// Initialise the custom loading view
- (void)initialiseLoadingView {
    
    self.customloadingView = [[LoadingView alloc] init];
    self.customloadingView.translatesAutoresizingMaskIntoConstraints = NO;
}

// Show loading screen
- (void)showLoadingView {
    
    [self.view addSubview:self.customloadingView];
    UIView *loadingView = self.customloadingView;
    NSDictionary *views = NSDictionaryOfVariableBindings(loadingView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[loadingView]|" options:0  metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[loadingView]|" options:0  metrics:nil views:views]];
    [self.view updateConstraints];
    [self.customloadingView updateConstraints];
    [self.customloadingView performSelector:@selector(startAnimations) withObject:nil afterDelay:0.3];
    
}

// Fetch FAQ from server
- (void)fetchFAQ {
    
    self.faqListArray = [NSArray arrayWithArray:[Faq allFaqDataForCurrentUser]];
    [faqTableVIew reloadData];

    if ( [self.faqListArray count] > 0 &&[[NSUserDefaults standardUserDefaults] objectForKey:FaqUpdatedDate]) {
        NSDate *lastUpdateDate = [EHHelpers dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:FaqUpdatedDate]];
        if ([[NSDate date] timeIntervalSinceDate:lastUpdateDate] < DAY_IN_SECONDS) {
            return;
        }
    }
    
    if ([EHHelpers isNetworkAvailable]) {
        User *currentuser = [APP_DELEGATE currentUser];
        
        if (currentuser) {
            NSString *soapAction = [NSString stringWithFormat:@"%@/GetFAQ", API_ACTION_ROOT];
            NSString *soapBodyXML = [NSString stringWithFormat:EHFAQ, currentuser.email, currentuser.guid,AppID] ;
            
            NSString *soapBody = [NSString stringWithFormat:SOAP_BODY_XML,  soapBodyXML];
            [self showLoadingView];
            [self.networkOperation fetchFAQWithBody:soapBody forAction:soapAction];
            
        }
        else {
            [EHHelpers showAlertWithTitle:@"" message:@"Invalid GUID. Please log in again" delegate:nil];
            [self logOutUser];
        }

    }
    else{
        [EHHelpers showAlertWithTitle:@"" message:@"No Network Available." delegate:nil];
    }
}

- (void)successFullyFetchedFAQData:(NSArray *)faqData{
    
    [self.customloadingView clearAllAnimations];
    [self.customloadingView removeFromSuperview];
    [self prepareFAQ:faqData];

}

- (void)error:(NSError *)operationError {

    [self.customloadingView clearAllAnimations];
    [self.customloadingView removeFromSuperview];
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
        if ([errorMessage isEqualToString:@"Invalid GUID. Please log in again"]) {
            [self logOutUser];
        }
    }

}
- (void)logOutUser {
    
    [APP_DELEGATE setCurrentUser:nil];
    [APP_DELEGATE stopSessionTimer];
    
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC.leftMenu performSegueWithIdentifier:@"showMedicineCabinetSegue" sender:nil];
}

- (void)prepareFAQ:(NSArray*)elements {
    
    [Faq prepareFaqData:elements];
    self.faqListArray = [NSArray arrayWithArray:[Faq allFaqDataForCurrentUser]];
    if ([self.faqListArray count] > 0) {
        [faqTableVIew reloadData];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[EHHelpers stringFromDate:[NSDate date] format:sqliteDateFormat] forKey:FaqUpdatedDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark IBActionMethods

- (IBAction)showMenu {
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}


#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.faqListArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == self.selectedIndex ? 1 : 0  ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section != self.selectedIndex) {
        return 0;
    }
    
    FaqTableCell *faqCell = (FaqTableCell *)[tableView dequeueReusableCellWithIdentifier:@"faqTableCellIdentifier"];
    if (!faqCell) {
        faqCell = [[[NSBundle mainBundle] loadNibNamed:@"FaqTableCell" owner:self options:nil] objectAtIndex:0];
    }
    
    Faq *faq = self.faqListArray[indexPath.section];
    
    NSString *answer = faq.answer;
    faqCell.answerTextView.attributedString = [self attributedStringWithString:answer size:18 withTextColor:@"#696969" withFontName:APPLICATION_FONT_NORMAL];
    [faqCell layoutIfNeeded];
    
    CGSize abSize = [faqCell.answerTextView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:faqCell.answerTextView.frame.size.width];
    
    return fmaxf(abSize.height + 20  + 1, 63) ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FaqTableCell *faqCell = (FaqTableCell *)[tableView dequeueReusableCellWithIdentifier:@"faqTableCellIdentifier"];
    if (!faqCell) {
        faqCell = [[[NSBundle mainBundle] loadNibNamed:@"FaqTableCell" owner:self options:nil] objectAtIndex:0];
    }
    
    Faq *faq = self.faqListArray[indexPath.section];
    NSString *answer = faq.answer;
    
    faqCell.answerTextView.attributedString = [self attributedStringWithString:answer size:18 withTextColor:@"#696969" withFontName:APPLICATION_FONT_NORMAL];
    faqCell.alpha = 0.0;
    [UIView animateWithDuration:0.8 animations:^{
        faqCell.alpha = 1.0;
    } completion:nil];
    return faqCell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    Faq *faq = self.faqListArray[section];
    NSString *question = faq.question;
    UIView *headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    headerContainerView.backgroundColor = ORANGE_COLOR;
    
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 72, 30)];
    textView.backgroundColor = [UIColor clearColor];
    textView.attributedString = [self attributedStringWithString:question size:18 withTextColor:@"#FFFFFF" withFontName:APPLICATION_FONT_BOLD];
    
    CGSize abSize = [textView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:textView.frame.size.width];
    
    CGRect textViewFrame = textView.frame;
    textViewFrame.size.height = abSize.height;
    textView.frame = textViewFrame;
    
    [headerContainerView addSubview:textView];
    
    
    CGRect  imageRect = CGRectMake(tableView.frame.size.width - 36, (abSize.height + 30)/2 - 12, 25, 24);
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:imageRect];
    
    NSString *imageName = (self.selectedIndex != section) ? @"faq_downarrow" : @"faq_uparrow";
    arrowImage.image = [UIImage imageNamed:imageName];
    
    [headerContainerView addSubview:arrowImage];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton setBackgroundColor:[UIColor clearColor]];
    [arrowButton setTag:section];
    [arrowButton addTarget:self action:@selector(showDropDown:) forControlEvents:UIControlEventTouchUpInside];
    arrowButton.frame = CGRectMake(0, 0, tableView.frame.size.width, abSize.height + 30);
    
    
    CGRect headerView = headerContainerView.frame;
    headerView.size.height = 15 + abSize.height + 15;
    headerContainerView.frame = headerView;
    
    [headerContainerView addSubview:arrowButton];
    
    return headerContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    
    Faq *faq = self.faqListArray[section];
    NSString *question = faq.question;
    
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 72, 30)];
    textView.attributedString = [self attributedStringWithString:question size:18 withTextColor:@"#205499" withFontName:APPLICATION_FONT_BOLD];
    
    CGSize abSize = [textView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:textView.frame.size.width];
    
    CGRect textViewFrame = textView.frame;
    textViewFrame.size.height = abSize.height;
    textView.frame = textViewFrame;
    
    
    return 15 + abSize.height + 15;
}

static NSString *defaultAttributedFontFamily = APPLICATION_FONT_NORMAL; // @"ChalkboardSE-Bold"

- (NSAttributedString*)attributedStringWithString:(NSString*)text size:(float)size withTextColor:(NSString*)colorString withFontName:(NSString*)fontName{
    
    NSData *data = [((text != nil) ? text : @"") dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:size], DTDefaultFontSize,
                             defaultAttributedFontFamily, DTDefaultFontFamily,
                             colorString, DTDefaultTextColor, fontName, DTDefaultFontName,
                             nil];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data
                                                                          options:options documentAttributes:NULL];
    
    return attrString;
}

- (void)showDropDown:(id)sender {
    
    int selectedTempIndex = (int)[sender tag];
    int currentIndex = self.selectedIndex;
    
    self.selectedIndex = -1;
    if (currentIndex >= 0) {
        [faqTableVIew reloadSections:[NSIndexSet indexSetWithIndex:currentIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
    self.selectedIndex = selectedTempIndex == currentIndex ? -1 : selectedTempIndex;
    [faqTableVIew reloadSections:[NSIndexSet indexSetWithIndex:selectedTempIndex] withRowAnimation:UITableViewRowAnimationFade];
    if (self.selectedIndex < 0) {
        return;
    }
    [faqTableVIew scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.selectedIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
