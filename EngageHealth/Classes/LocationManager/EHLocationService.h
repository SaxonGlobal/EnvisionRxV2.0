//
//  EHLocationService.h
//  Envisionrx
//
//  Created by Nassif on 19/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EHLocationService : NSObject <CLLocationManagerDelegate>

+ (EHLocationService *) sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (void)startUpdatingLocationService;
- (void)stopUpdatingLocationService;

@end
