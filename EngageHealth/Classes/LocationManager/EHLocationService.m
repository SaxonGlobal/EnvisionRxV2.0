//
//  EHLocationService.m
//  Envisionrx
//
//  Created by Nassif on 19/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "EHLocationService.h"

@implementation EHLocationService

+(EHLocationService *) sharedInstance
{
    static EHLocationService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100; // meters
        self.locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }

    }
    return self;
}

- (void)startUpdatingLocationService
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [self stopUpdatingLocationService];
                break;
            case kCLErrorLocationUnknown:
                break;
            default:
                break;
        }
    }
}

//Stops the location manager from getting user location
- (void)stopUpdatingLocationService {
    
    if(self.locationManager) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

@end
