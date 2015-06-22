//
//  AppDelegate.m
//  EngageHealth
//
//  Created by Nithin Nizam on 21/07/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Bugsnag.h"
#import "EncryptedStore.h"
#import <Security/Security.h>
#import "GAI.h"
//Dasari dineshbabu
@implementation AppDelegate

static NSString *serviceName = @"com.infoalchemy.envisionRx";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Bugsnag startBugsnagWithApiKey:kBugSnagAPIKey]; //Error catching
    [[AFNetworkReachabilityManager sharedManager] startMonitoring]; //Network status monitoring
    [[EHLocationService sharedInstance] startUpdatingLocationService]; //Location services
    
    self.networkOperation = [[EHOperation alloc] initWithDelegate:self];
    [AlertHandler checkIfAppHasPreviousNotification];
    [self loadSecurityQuestions];
    [self checkVersion];
    
    //Enabling GA tracking
    [[GAI sharedInstance] setDispatchInterval:30];
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKING];
    
    return YES;
}

#pragma mark
#pragma mark SecurityQuestion

- (void)loadSecurityQuestions {
    
    if ([EHHelpers fileExistsAtDocDir:Security_Question_File]) {
        self.securityQuestions = [NSMutableArray arrayWithArray:[EHHelpers arrayFromFile:Security_Question_File]];
        
    }
    else {
        
        NSString *soapAction = [NSString stringWithFormat:@"%@/GetSecurityQuestions", API_ACTION_ROOT];
        NSString *soapBodyXML = [NSString stringWithFormat:EHSecurityQuestion] ;
        NSString *soapBody = [NSString stringWithFormat:AUTH_SOAP_BODY_XML_2, soapBodyXML];
        [self.networkOperation loadSecurityQuestionsWithSoapBody:soapBody forAction:soapAction];
    }
}

- (void)successFullyLoadedSecurityQuestionData:(NSArray *)data{
    [self cacheSecurityQuestions:data];;
}

- (void)error:(NSError *)operationError {
    
    NSString *errorMessage = [EHHelpers errorMessageForError:operationError];
    if ([errorMessage length] > 0) {
        [EHHelpers showAlertWithTitle:@"" message:errorMessage delegate:nil];
    }
    
}

- (void)cacheSecurityQuestions:(NSArray*)questions {
    
    self.securityQuestions = [NSMutableArray array];
    for (DDXMLElement *element in questions) {
        NSMutableDictionary *questionDict = [NSMutableDictionary dictionary];
        questionDict[@"id"] = [EHHelpers xmlElementValueForKey:@"QuestionID" forXmlElement:element];
        questionDict[@"text"] = [EHHelpers xmlElementValueForKey:@"Question" forXmlElement:element];
        [self.securityQuestions addObject:questionDict];
        
    }
    [EHHelpers writeArrayToPlist:Security_Question_File array:[NSArray arrayWithArray:self.securityQuestions]];
}
//check for app updates
- (void)checkVersion {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:@"LastVersionCheck"] != nil) {
        NSDate *lastUpdateDate = [userDefaults objectForKey:@"LastVersionCheck"];
        if ([[NSDate date] timeIntervalSinceDate:lastUpdateDate] < DAY_IN_SECONDS) {
            return;
        }
    }
    [self.networkOperation getSupportedVersion];
}

- (void)successfullyRetrievedSupportVersionCheckData:(NSArray *)data {
    
    if ([data count] > 0) {
        NSString *version = [(DDXMLElement*)data[0] stringValue];
        [self processAppVersion:version];
        [EHHelpers syncDefaults:@"Version" dataToSync:version];
        [EHHelpers syncDefaults:@"LastVersionCheck" dataToSync:[NSDate date]];
    }
}


- (void)deleteExpiredNotifications {
    
    [AlertHandler deleteExpiredNotifications];
    
}

- (EHWindow *)window
{
    static EHWindow *customWindow = nil;
    if (!customWindow) {
        customWindow = [[EHWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return customWindow;
}


- (void)timeout {
    
    NSString *timeOutMinutes = kLoginExpiration;
    NSDate *timeAsOfLastActivity = [EHHelpers dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey: @"timeOfLastActivity"]];
    
    if (timeAsOfLastActivity && [timeOutMinutes intValue] > 0 && [[NSDate date] timeIntervalSinceDate:timeAsOfLastActivity] > ([timeOutMinutes intValue] * 60)){
        [self logout];
    }
}

- (void)logout {
    
    [self stopSessionTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"_Logout_TimeOut_" object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"timeOfLastActivity"];
}


- (void)initiateSessionTimer {
    
    [self stopSessionTimer];
    [[NSUserDefaults standardUserDefaults] setObject:[EHHelpers stringFromDate:[NSDate date] format:kDefaultDateFormat]  forKey:@"timeOfLastActivity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelectorOnMainThread:@selector(startSessionTimer) withObject:nil waitUntilDone:NO];
}


- (void)startSessionTimer {
    
    [self stopSessionTimer];
    
    if(self.sessionTimer == nil){
        
        self.sessionTimer =  [NSTimer scheduledTimerWithTimeInterval:5
                                                              target:self
                                                            selector:@selector(timeout)
                                                            userInfo:nil
                                                            repeats:YES];
        [self.sessionTimer fire];
        
    }
}

- (void)stopSessionTimer {
    
    if(self.sessionTimer){
        [self.sessionTimer invalidate];
        self.sessionTimer = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[EHLocationService sharedInstance] stopUpdatingLocationService];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    if ([[EHLocationService sharedInstance].locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[EHLocationService sharedInstance].locationManager requestWhenInUseAuthorization];
    }
    
    [[EHLocationService sharedInstance].locationManager startMonitoringSignificantLocationChanges];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    [self setCurrentUser:nil];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [[[UIAlertView alloc] initWithTitle:@"" message:notification.alertBody delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
    
    if ([notification.userInfo[@"sound"] length] > 0) {
        
        NSString *path = notification.userInfo[@"sound"];
        
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"m4r"];
        
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL URLWithString:soundPath],&soundID);
        AudioServicesPlayAlertSound(soundID);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertNotification" object:nil];
    [self performSelectorInBackground:@selector(deleteExpiredNotifications) withObject:nil];
    
}

#pragma mark
#pragma mark Version Check Update

- (void)processAppVersion:(NSString *)versionString {
    
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([currentVersion length] == 0)
    {
        currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    
    if (!currentVersion || [currentVersion isEqualToString:versionString]) {
        return;
    }
    currentVersion = [NSString stringWithFormat:@"%@.0", currentVersion];
    NSArray *versionSplits = [versionString componentsSeparatedByString:@"."];
    NSArray *currentVersionSplits = [currentVersion componentsSeparatedByString:@"."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"kAppstoreVersion"]) {
        [defaults removeObjectForKey:@"kAppstoreVersion"];
        [defaults removeObjectForKey:@"Update Required"];
        [defaults synchronize];
    }
    
    if ([versionSplits count] > 0 && [currentVersionSplits count] > 0) {
        if ([versionSplits[0] intValue] > [currentVersionSplits[0] intValue]) {
            //Major Update
            [defaults setObject:versionString forKey:@"kAppstoreVersion"];
            [defaults setObject:@"Update Required" forKey:@"kUpdateRequired"];
            [defaults synchronize];
            [self majorUpdateAvailable];
            return;
        }
        if (([versionSplits count] > 1 && [currentVersionSplits count] > 1) && ([versionSplits[1] intValue] > [currentVersionSplits[1] intValue])) {
            //Moderate Update
            [self moderateUpdateAvailable];
            return;
        }
        if (([versionSplits count] > 2 && [currentVersionSplits count] > 2) && ([versionSplits[2] intValue] > [currentVersionSplits[2] intValue])) {
            //Minor Update
            [self minorUpdateAvailable];
            return;
        }
    }
}

- (void)minorUpdateAvailable {
    UIAlertView *minorUpdate = [[UIAlertView alloc] initWithTitle:@"Update Available" message:@"A newer version of this app is available in the app store. Consider updating." delegate:self cancelButtonTitle:@"Update" otherButtonTitles:@"OK", nil];
    minorUpdate.tag = 999;
    [minorUpdate show];
}

- (void)moderateUpdateAvailable {
    UIAlertView *moderateUpdate = [[UIAlertView alloc] initWithTitle:@"Update Available" message:@"A newer version of this app is available in the app store. Consider updating." delegate:self cancelButtonTitle:@"Update" otherButtonTitles:@"OK", nil];
    moderateUpdate.tag = 999;
    [moderateUpdate show];
}

- (void)majorUpdateAvailable {
    UIAlertView *majorUpdate = [[UIAlertView alloc] initWithTitle:@"Update Required" message:@"You must update to the latest version of this app to continue. Please update now." delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
    majorUpdate.tag = 999;
    [majorUpdate show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag != 999) {
        return;
    }
    NSURL *appStoreUrl = [NSURL URLWithString:ITUNES_URL];
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:appStoreUrl];
    }
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSString *passcode = [EHHelpers uuid];
    
    NSData *passwordData = [self searchKeychainCopyMatching:@"CoreDataKey"];
    if (passwordData) {
        passcode = [[NSString alloc] initWithData:passwordData
                                         encoding:NSUTF8StringEncoding];
    }
    else {
        [self createKeychainValue:passcode forIdentifier:@"CoreDataKey"];
    }
    
    NSPersistentStoreCoordinator *coordinator = [EncryptedStore makeStore:[self managedObjectModel] passcode:passcode];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EngageHealth" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EngageHealth.sqlite"];
    NSError *error = nil;
    NSDictionary *storeOptions = @{NSPersistentStoreFileProtectionKey  : NSFileProtectionComplete};
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLOG(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Keychain Access

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef result = NULL;
    BOOL statusCode = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    if (statusCode == errSecSuccess) {
        NSData *resultData = CFBridgingRelease(result);
        return resultData;
    }
    return nil;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL)deleteKeychainValueForIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
      
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}


@end
