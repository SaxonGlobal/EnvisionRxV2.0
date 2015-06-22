//
//  EHHelpers.m
//  EngageHealth
//
//  Created by Nithin on 4/16/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import "EHHelpers.h"
#import <objc/runtime.h>


@implementation EHHelpers

+ (BOOL)isIpadDevice {
    NSString *deviceType = [UIDevice currentDevice].model;
    NSRange aRange = [deviceType rangeOfString:@"iPad"];
    return (aRange.location == NSNotFound)?NO:YES;
}

+ (BOOL)isIphone5Device {
    return (![EHHelpers isIpadDevice] && [[UIScreen mainScreen] bounds].size.height > 480.0f) ? YES : NO;
}

+ (BOOL)isIOS7 {
    NSString *version = [UIDevice currentDevice].systemVersion;
    NSRange aRange = [version rangeOfString:@"7."];
    return (aRange.location != NSNotFound && aRange.location == 0)?YES:NO;
}

+ (NSMutableAttributedString *)getHeaderText {
    NSString *str = @"Engage Health - Envision";
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:str];
    
    [attString addAttribute:NSObliquenessAttributeName
                      value:[NSNumber numberWithFloat:.20]
                      range:NSMakeRange(4,3)];
    return attString;
}

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
// If it does not exist, copy the default plist to the appropriate location.
+ (void)copyFileIfNeeded:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *destPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:destPath];
    if (fileExists) {
        return;
    }
    
    // The writable plist does not exist, so copy the default to the appropriate location.
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager]
                    copyItemAtPath:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]
                    toPath:destPath
                    error:&error];
    
    if (!success) {
        NSAssert1(NO, @"Failed to copy the plist file with message '%@'.", [error localizedDescription]);
    }
}

+ (NSArray *)arrayFromFile:(NSString *)fileName {
    NSString *resourcePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    
    NSArray *fileData = [NSArray arrayWithContentsOfFile:resourcePath];
    return fileData;
}

+ (void)writeData:(NSData *)data toFile:(NSString *)fileName {
    NSString *resourcePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    [data writeToFile:resourcePath atomically:YES];
}
+ (NSData *)dataFromFile:(NSString *)fileName {
    NSString *resourcePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    
    NSData *fileData = [NSData dataWithContentsOfFile:resourcePath];
    return fileData;
}

+ (CGFloat)getStatusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}


+ (void)setBorderFor:(UIView *)view withColor:(UIColor *)borderColor width:(float)width {
    [view.layer setBorderColor:borderColor.CGColor];
    view.layer.borderWidth = width;
}

+ (void)setBorderFor:(UIView *)view withColor:(UIColor *)borderColor width:(float)width withCorner:(float)radius{
    [view.layer setBorderColor:borderColor.CGColor];
    view.layer.borderWidth = width;
    view.layer.cornerRadius = radius;
}

+ (CGFloat)calculateHeightForText:(NSString*)textString forSize:(CGSize)size {
    
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:textString
     attributes:@
     {
     NSFontAttributeName: [UIFont fontWithName:APPLICATION_FONT_NORMAL size:17]
     }];
    
    
    CGRect frame = [attributedText boundingRectWithSize:size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
    
    
    return frame.size.height;
}

+ (UIColor *) colorWithHexString: (NSString *)stringToConvert{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (void)animateViewToFrame:(CGRect )newframe duration:(float)duration view:(id)view{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [view setFrame:newframe];
    [UIView commitAnimations];
}


//Date methods
static NSArray *dateFormats = nil;
static NSString *kSQLiteDateFormat = @"yyyy/MM/dd HH:mm:ss Z";
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *result = [formatter stringFromDate:date];
    return result;
}

+ (NSArray *)dateFormats {
    if (!dateFormats) {
        dateFormats = [[NSArray alloc] initWithObjects:
                       kSQLiteDateFormat,
                       @"MMM-YYYY",
                       @"yyyy-MM-dd",
                       @"yyyy-12",
                       @"yyyy/MM/dd",
                       @"yyyy/mm/dd",
                       @"yyyy-MM-dd HH:mm:ss Z",
                       @"yyyy-MM-dd HH:mm:ss K",
                       @"yyyy-MM-dd HH:mm:ss ZZ",
                       @"yyyy/MM/dd hh:mm a",
                       @"MM/dd/yyyy",
                       @"MM/dd/yyyy HH:mm:ss Z",
                       @"h:mm a",
                       @"hh:mm a",
                       @"yyyy/MM/dd HH:mm:ss Z",
                       @"yyyy/MM/dd h:mm a",
                       @"MM/dd/yyyy h:mm a",
                       @"yyyy-MM-dd h:mm a",
                       @"yyyy-MM-dd'T'hh:mm:ss",
                       @"yyyy/MM/dd h a",
                       nil];
    }
    return dateFormats;
}

//To get date as NSDate from NSString with the specified format.
+ (NSDate *)dateFromString:(NSString *)dateString {
    if (!dateString) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    NSDate *date;
    for (NSString *format in [self dateFormats]) {
        [formatter setDateFormat:format];
        date = [formatter dateFromString:dateString];
        if (date) {
            return date;
        }
    }
    
    return nil;
}

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate {
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

+ (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)messageString delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:messageString
                                                   delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:  nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

+(NSString *) stringByTrimmingWhitespaceFromFront:(NSString*)str
{//To remove leading white space
    const char *cStringValue = [str UTF8String];
    
    int i;
    for (i = 0; cStringValue[i] != '\0' && isspace(cStringValue[i]); i++);
    
    return [str substringFromIndex:i];
}

+(NSString *)stringByStrippingHTML:(NSString*)str
{
    str = [str stringByTrimmingCharactersInSet:
           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    str = [str stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"   " withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    NSRange r;
    while ((r = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location     != NSNotFound)
    {
        str = [str stringByReplacingCharactersInRange:r withString:@""];
    }
    str = [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"&deg;" withString:@"65\u00B0"];
    str = [str stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"& "];
    str = [self stringByTrimmingWhitespaceFromFront:str];
    return str;
}


// To save data to defaults
+ (void)syncDefaults:(NSString *)userDefaultKey dataToSync:(id)data {
    
    NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:userDefaultKey];
    [defaults synchronize];
}

+ (NSData *)convertToNSData:(id)obj {
    const void *buffer = NULL;
    size_t size = 0;
    dispatch_data_t new_data_file = dispatch_data_create_map(obj, &buffer, &size);
    if(new_data_file){ /* to avoid warning really - since dispatch_data_create_map demands we care about the return arg */}
    return [[NSData alloc] initWithBytes:buffer length:size];
    return [NSData data];
}

+(NSString*)formatToPhoneNumber:(NSString *)number {
    
    
    if(number.length > 9) {
        NSArray *stringComponents = [NSArray arrayWithObjects:[number substringWithRange:NSMakeRange(0, 3)],
                                     [number substringWithRange:NSMakeRange(3, 3)],
                                     [number substringWithRange:NSMakeRange(6, [number length]-6)], nil];
        
        NSString *formattedString = [NSString stringWithFormat:@"%@-%@-%@", [stringComponents objectAtIndex:0], [stringComponents objectAtIndex:1], [stringComponents objectAtIndex:2]];
        return formattedString;
    } else {
        return @"";
    }
    
}

+ (BOOL)canUseMKMapItem {
    Class itemClass = [MKMapItem class];
    return (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]);
    
}

+ (NSString*)repeatStatusForDrug:(NSDictionary*)repeatStatus {
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *repeatIntervals = [[repeatStatus allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSString *repeatPeriod = @"";
    
    
    if ([repeatIntervals count] == 0) {
        repeatPeriod = @"Never";
    }
    else if ([repeatIntervals count] == 7) {
        repeatPeriod = @"Everyday";
    }
    else if ([repeatIntervals count] <= 6) {
        if (repeatStatus[@"1"] != nil && repeatStatus[@"7"] != nil && [repeatIntervals count] == 2) {
            repeatPeriod = @"Weekend";
        }
        else {
            if ([repeatIntervals count] == 5 && repeatStatus[@"1"] == nil && repeatStatus[@"7"] == nil) {
                repeatPeriod = @"Weekdays";
            }
            else {
                
                NSMutableArray *repeatedDays = [NSMutableArray array];
                for (NSString *day in repeatIntervals) {
                    [repeatedDays addObject:[[self class] dayOrdinalOfWeekOrdinal:day]];
                }
                if ([repeatedDays count] > 0) {
                    repeatPeriod = [repeatedDays componentsJoinedByString:@","];
                }
            }
        }
    }
    
    return repeatPeriod;
}

+ (NSString*)dayOrdinalOfWeekOrdinal:(NSString*)dayOrdinal{
    
    NSString *day = @"";
    
    switch ([dayOrdinal intValue]) {
        case 2:
            day = @"Mon";
            break;
        case 3:
            day = @"Tue";
            break;
            
        case 4:
            day = @"Wed";
            break;
        case 5:
            day = @"Thu";
            break;
        case 6:
            day = @"Fri";
            break;
        case 7:
            day = @"Sat";
            break;
        case 1:
            day = @"Sun";
            break;
            
        default:
            break;
    }
    return day;
}


+ (NSString *)removeCharsAndCapitalise:(NSString *)inputString {
    NSArray *charSetArray = @[@"_", @"-", @"|", @"!"];
    
    for (NSString *str in charSetArray) {
        inputString = [inputString stringByReplacingOccurrencesOfString:str withString:@" "];
        inputString = [inputString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    return [inputString capitalizedString];
}


// Remove the selected notification
+ (void)removeNotification:(NSDictionary*)notificationDrug {
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"startDate"] compare:notificationDrug[@"startDate"]] == NSOrderedSame) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
}
+ (BOOL)writeArrayToPlist:(NSString *)fileName array:(NSArray*)plistArray {
    
    NSString *writablePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    return [plistArray writeToFile:writablePath atomically:YES];
}


+ (BOOL)isLocationServiceActive {
    
    BOOL active = NO;
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        active = YES;
    }
    return active;
    
}

+ (NSString*)xmlElementValueForKey:(NSString*)key forXmlElement:(DDXMLElement*)xmlElement {
    
    NSString *stringValue = @"";
    NSArray *elements = [xmlElement elementsForName:key];
    
    if ([elements count] > 0) {
        
        id obj = elements[0];
        stringValue = [obj stringValue];
    }
    
    return stringValue;
    
    
}

+ (NSString*)stringByRemovingSpecialCharacters:(NSString*)actualString {
    
    
    NSString *resultString = [actualString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"*" withString:@""];
    return resultString;
}

+ (BOOL)fileExistsAtDocDir:(NSString*)fileName {
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
}

+ (NSString*)errorMessageForError:(NSError*)error {
    
    NSDictionary *xml = [XMLReader dictionaryForXMLData:error.userInfo[@"com.alamofire.serialization.response.error.data"] error:&error];
    
    NSString *errorMessage = @"";
    
    if (xml[@"soap:Envelope"][@"soap:Body"][@"soap:Fault"][@"detail"][@"ErrorInfo"][@"xmlns"]) {
        errorMessage = xml[@"soap:Envelope"][@"soap:Body"][@"soap:Fault"][@"detail"][@"ErrorInfo"][@"xmlns"];
    }
    else if (xml[@"soap:Envelope"][@"soap:Body"][@"soap:Fault"][@"faultstring"]) {
        
        errorMessage = xml[@"soap:Envelope"][@"soap:Body"][@"soap:Fault"][@"faultstring"][@"value"];
    }
    ;
    return errorMessage;
}


+ (BOOL)checkForEmailValidation:(NSString*)email {
    
    NSString *emailRegex = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (BOOL)validateEmail:(NSString *)email {
    //Based on the string below
    //NSString *strEmailMatchstring=@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    
    //Quick return if @ Or . not in the string
    if([email rangeOfString:@"@"].location==NSNotFound || [email rangeOfString:@"."].location==NSNotFound)
        return NO;
    
    //Break email address into its components
    NSString *accountName=[email substringToIndex: [email rangeOfString:@"@"].location];
    email=[email substringFromIndex:[email rangeOfString:@"@"].location+1];
    
    //'.' not present in substring
    if([email rangeOfString:@"."].location==NSNotFound)
        return NO;
    NSString *domainName=[email substringToIndex:[email rangeOfString:@"."].location];
    NSString *subDomain=[email substringFromIndex:[email rangeOfString:@"."].location+1];
    
    //username, domainname and subdomain name should not contain the following charters below
    //filter for user name
    NSString *unWantedInUName = @" ~!@#$%^&*()={}[]|;':\"<>,+?/`";
    
    //filter for domain
    NSString *unWantedInDomain = @" ~!@#$%^&*()={}[]|;’:\"<>,+?/`";
    
    //filter for subdomain
    NSString *unWantedInSub = @" `~!@#$%^&*()={}[]:\";'<>,?/1234567890";
    
    //subdomain should not be less that 2 and not greater 6
    if(!(subDomain.length>=2 && subDomain.length<=6)) return NO;
    
    if([accountName isEqualToString:@""] || [accountName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInUName]].location!=NSNotFound || [domainName isEqualToString:@""] || [domainName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInDomain]].location!=NSNotFound || [subDomain isEqualToString:@""] || [subDomain rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInSub]].location!=NSNotFound)
        return NO;
    
    return YES;
}

+ (BOOL)validatePassword:(NSString *)passWord {
    
    int checkCount = 0;
    
    NSRange range;
    range = [passWord rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if (range.location != NSNotFound) {
        checkCount++;
    }
    range = [passWord rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    if (range.location != NSNotFound) {
        checkCount++;
    }
    range = [passWord rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (range.location != NSNotFound) {
        checkCount++;
    }
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    range = [passWord rangeOfCharacterFromSet:set];
    if (range.location != NSNotFound) {
        checkCount++;
    }
    return ([passWord length] >= 6 && checkCount >= 3) ? YES : NO;
    
}


static NSString *defaultAttributedFontColor = @"#33607E";
static NSString *defaultAttributedFontFamily = APPLICATION_FONT_NORMAL; // @"ChalkboardSE-Bold"
static NSString *defaultAttributedFontFace = APPLICATION_FONT_NORMAL;
static float defaultFontSize = 17.0;

+ (NSAttributedString*)attributedStringWithString:(NSString*)text {
    return [[self class] attributedStringWithString:text size:defaultFontSize];
}

+ (NSAttributedString*)attributedStringWithString:(NSString*)text size:(float)size {
    
    NSData *data = [((text != nil) ? text : @"") dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:size], DTDefaultFontSize,
                             defaultAttributedFontFamily, DTDefaultFontFamily,
                             defaultAttributedFontColor, DTDefaultTextColor, defaultAttributedFontFace, APPLICATION_FONT_NORMAL,
                             nil];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data
                                                                          options:options documentAttributes:NULL];
    
    return attrString;
}

+ (NSString*)loadDefaultSettingsForKey:(NSString*)keyString withDefaultValue:(int)defaultSettingValue {
    
    User *currentUser = [APP_DELEGATE currentUser];
    NSString *keyValue = [NSString stringWithFormat:@"%d",defaultSettingValue];
    
    if (currentUser) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userKey = [NSString stringWithFormat:@"Profile-%@",currentUser.email];
        NSDictionary *settingsDict = ([defaults objectForKey:userKey] != nil ) ? [NSDictionary dictionaryWithDictionary:[defaults objectForKey:userKey]] : [NSDictionary dictionary];
        
        keyValue = (settingsDict[keyString] != nil )?  [NSString stringWithFormat:@"%d",[settingsDict[keyString] intValue]]: [NSString stringWithFormat:@"%d",defaultSettingValue] ;
        
    }
    return keyValue;
}


+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (NSString *)CFBridgingRelease(uuidStringRef);
}

+ (NSString*)commmaSeparatedStringForDigit:(int)digit {
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *commaString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:digit]];
    return commaString;
}

+ (BOOL)isNetworkAvailable {
    
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

+ (void)underlineButtonText:(UIButton *)underlineButton withString:(NSString *)textString {

    NSMutableAttributedString *underLineText = [[NSMutableAttributedString alloc] initWithString:textString];
    [underLineText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [underLineText length])];
    [underlineButton setAttributedTitle:underLineText forState:UIControlStateNormal];
    
}

+ (void)registerGAWithCategory:(NSString *)categoryString forAction:(NSString *)actionString{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryString            // Event category (required)
                                                          action:actionString  // Event action (required)
                                                           label:nil              // Event label
                                                           value:nil] build]];

}
@end

@implementation NSManagedObject(eh)

+ (NSString *)entityName
{
    return [NSString stringWithUTF8String:class_getName([self class])];
}

@end
