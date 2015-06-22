//
//  AlternateDrug+DAO.m
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "AlternateDrug+DAO.h"

@implementation AlternateDrug (DAO)


+ (AlternateDrug*)insertNewDrug:(DDXMLElement *)dataElement {
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    AlternateDrug *obj = [NSEntityDescription insertNewObjectForEntityForName:[AlternateDrug entityName] inManagedObjectContext:context];
    
    obj = [[self class] populateAlternativeDrug:dataElement withObj:obj];

    NSError *error;
    if (![context save:&error]) {
        NSLOG(@"Error in inserting alternate Drug Object - error:%@" ,error);
    }
    
    return obj;
    
}

+ (AlternateDrug*)populateAlternativeDrug:(DDXMLElement *)drugData withObj:(AlternateDrug *)altDrugObj{
    
    [altDrugObj setName:[EHHelpers xmlElementValueForKey:@"PRODDESCABBREV" forXmlElement:drugData]];
    [altDrugObj setNdc:[EHHelpers xmlElementValueForKey:@"NDCUPCHRI" forXmlElement:drugData]];
    [altDrugObj setErrorMessage:@""];
    [altDrugObj setCopay:@""];
    [altDrugObj setStatus:[NSNumber numberWithInt:0]];
    [altDrugObj setSavings:[NSNumber numberWithFloat:-1]];
    
    return altDrugObj;
    
}
@end
