//
//  EHHelpers.h
//  EngageHealth
//
//  Created by Nithin on 4/16/14.
//  Copyright (c) 2014 Mobomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DTCoreText.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "DDXML.h"
#import "XMLReader.h"
#import "Constants.h"

@interface EHHelpers : NSObject

+ (BOOL)isIpadDevice;
+ (BOOL)isIphone5Device;
+ (BOOL)isIOS7;
+ (NSMutableAttributedString *)getHeaderText;
+ (CGFloat)getStatusBarHeight;
+ (CGFloat)calculateHeightForText:(NSString*)textString forSize:(CGSize)size;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
+ (void)animateViewToFrame:(CGRect )newframe duration:(float)duration view:(id)view;
+ (void)setBorderFor:(UIView *)view withColor:(UIColor *)borderColor width:(float)width;
+ (void)setBorderFor:(UIView *)view withColor:(UIColor *)borderColor width:(float)width withCorner:(float)radius;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString*)format;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+ (NSArray *)dateFormats;
+ (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)messageString delegate:(id)delegate ;
+(NSString *)stringByStrippingHTML:(NSString*)str;
+(NSString *) stringByTrimmingWhitespaceFromFront:(NSString*)str;
+ (void)syncDefaults:(NSString *)userDefaultKey dataToSync:(id)data;
+ (NSArray *)arrayFromFile:(NSString *)fileName;
+ (NSData *)dataFromFile:(NSString *)fileName;
+ (void)copyFileIfNeeded:(NSString *)fileName;
+ (NSData *)convertToNSData:(id)obj;
+ (void)writeData:(NSData *)data toFile:(NSString *)fileName;
+(NSString*)formatToPhoneNumber:(NSString *)number ;
+ (BOOL)canUseMKMapItem ;

+ (NSString*)repeatStatusForDrug:(NSDictionary*)repeatStatus;
+ (NSString*)dayOrdinalOfWeekOrdinal:(NSString*)dayOrdinal;
+ (NSString *)removeCharsAndCapitalise:(NSString *)inputString;
+ (void)removeNotification:(NSDictionary*)notificationDrug;
+ (BOOL)writeArrayToPlist:(NSString *)fileName array:(NSArray*)plistArray;

+ (BOOL)isLocationServiceActive;
+ (NSString*)xmlElementValueForKey:(NSString*)key forXmlElement:(DDXMLElement*)xmlElement;
+ (NSString*)stringByRemovingSpecialCharacters:(NSString*)actualString;
+ (BOOL)fileExistsAtDocDir:(NSString*)fileName;
+ (NSString*)errorMessageForError:(NSError*)error;
+ (BOOL)validateEmail:(NSString *)email;
+ (BOOL)checkForEmailValidation:(NSString*)email;
+ (NSAttributedString*)attributedStringWithString:(NSString*)text;
+ (NSAttributedString*)attributedStringWithString:(NSString*)text size:(float)size;
+ (NSString*)loadDefaultSettingsForKey:(NSString*)keyString withDefaultValue:(int)defaultSettingValue;
+ (NSString *)uuid;
+ (NSString*)commmaSeparatedStringForDigit:(int)digit;
+ (BOOL)isNetworkAvailable;
+ (void)underlineButtonText:(UIButton*)underlineButton withString:(NSString*)textString;
+ (void)registerGAWithCategory:(NSString*)categoryString forAction:(NSString*)actionString;
+ (BOOL)validatePassword:(NSString *)passWord;
@end


@interface NSManagedObject (eh)

+ (NSString *)entityName;

@end
