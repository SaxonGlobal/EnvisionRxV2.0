//
//  Drugs+DAO.m
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "Drugs+DAO.h"

@implementation Drugs (DAO)


+ (Drugs*)insertNewDrug:(NSDictionary *)drug{
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];

    Drugs *obj = [NSEntityDescription insertNewObjectForEntityForName:[Drugs entityName] inManagedObjectContext:context];
    
    obj = [[self class] populateDrugData:drug withObj:obj];
    
    
    NSError *error;
    if (![context save:&error]) {
        NSLOG(@"Error in inserting new Drug Object - error:%@" ,error);
    }
    
    return obj;

}

+ (Drugs*)populateDrugData:(NSDictionary *)drugElement withObj:(Drugs *)drugObj {
    
    drugObj.ndc = drugElement[@"NDCUPCHRI"];;
    drugObj.multisource = drugElement[@"MULTISOURCE"];
    drugObj.proddescabbrev = drugElement[@"PRODDESCABBREV"];;
    drugObj.otc = [NSNumber numberWithBool:[drugElement[@"PRODDESCABBREV"] boolValue]];
    drugObj.gpi = drugElement[@"GPI"];
    return drugObj;
    
}
@end
