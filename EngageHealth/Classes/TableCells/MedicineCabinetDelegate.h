//
//  MedicineCabinetDelegate.h
//  Envisionrx
//
//  Created by Nassif on 28/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MedicineCabinetDelegate <NSObject>

@optional
// Claims
- (void)showAlarmsForDrugIndex:(int)drugIndex;
- (void)showDrugInfo:(int)drugIndex;
- (void)drugRenewalRefill:(int)drugIndex;

// Manual Drug
- (void)deleteDrug:(int)drugIndex;

@end
