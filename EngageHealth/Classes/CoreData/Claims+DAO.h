//
//  Claims+DAO.h
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "Claims.h"
#import "AlternateDrug+DAO.h"
#import "Drugs+DAO.h"
#import "Constants.h"

@interface Claims (DAO)


+ (void)prepareAlternativeDrugData:(NSArray*)alternativeDrugData forClaims:(Claims*)drugClaim ;
+ (Claims*)insertNewClaimData:(NSDictionary*)claimData;
+ (Claims*)populateCliamData:(NSDictionary*)claimData withObj:(Claims*)claimObj;
@end
