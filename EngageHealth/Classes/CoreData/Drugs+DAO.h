//
//  Drugs+DAO.h
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "Drugs.h"
#import "Constants.h"

@interface Drugs (DAO)

+ (Drugs*)insertNewDrug:(NSDictionary*)drug;
+ (Drugs*)populateDrugData:(NSDictionary*)drugElement withObj:(Drugs*)drugObj;
@end
