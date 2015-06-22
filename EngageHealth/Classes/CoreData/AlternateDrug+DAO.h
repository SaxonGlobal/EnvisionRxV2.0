//
//  AlternateDrug+DAO.h
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AlternateDrug.h"
#import "Constants.h"
#import "EHHelpers.h"

@interface AlternateDrug (DAO)

+ (AlternateDrug*)insertNewDrug:(DDXMLElement*)dataElement;
+ (AlternateDrug*)populateAlternativeDrug:(DDXMLElement*)drugData withObj:(AlternateDrug*)altDrugObj;
@end
