//
//  AppDelegate.h
//  EngageHealth
//
//  Created by Nithin Nizam on 21/07/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "User.h"
#import "XMLReader.h"
#import "DDXML.h"
#import "EHWindow.h"
#import "EHLocationService.h"
#import "EHOperation.h"
#import "AlertHandler.h"
#import "EHHelpers.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate,EHOperationProtocol>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) User *currentUser;
@property (nonatomic ,strong) NSMutableArray *securityQuestions;

@property (nonatomic, strong) NSTimer *sessionTimer;
@property (nonatomic,strong) EHLocationService *locationServiceManager;
@property (nonatomic ,strong) EHOperation *networkOperation;

- (void)initiateSessionTimer;
- (void)stopSessionTimer;
- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
- (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
- (BOOL)deleteKeychainValueForIdentifier:(NSString *)identifier;

@end
