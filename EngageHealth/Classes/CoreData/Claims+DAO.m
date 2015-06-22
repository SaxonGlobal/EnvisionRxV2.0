//
//  Claims+DAO.m
//  Envisionrx
//
//  Created by nassif on 22/11/14.
//  Copyright (c) 2014 Mobomo LLC. All rights reserved.
//

#import "Claims+DAO.h"

@implementation Claims (DAO)


+ (void)prepareAlternativeDrugData:(NSArray *)alternativeDrugData forClaims:(Claims *)drugClaim{
    
    NSManagedObjectContext *ctx = [APP_DELEGATE managedObjectContext];
    [drugClaim removeAlternateDrug:[drugClaim alternateDrug]];
    
    for (DDXMLElement *drugElement in alternativeDrugData) {
        AlternateDrug *drug = [AlternateDrug insertNewDrug:drugElement];
        drug.claim = drugClaim;
        [drugClaim addAlternateDrugObject:drug];
    }
    [ctx save:nil];
}

+ (Claims*)insertNewClaimData:(NSDictionary *)claimData {
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    Claims *obj = [NSEntityDescription insertNewObjectForEntityForName:[Claims entityName] inManagedObjectContext:context];
    
    obj = [[self class] populateCliamData:claimData withObj:obj];
    
    
    NSError *error;
    if (![context save:&error]) {
        NSLOG(@"Error in inserting Drug Object - error:%@" ,error);
    }
    
    return obj;
    
}

+ (Claims*)populateCliamData:(NSDictionary *)claimData withObj:(Claims *)claimObj {
    
    [claimObj setPlanPaid:[NSNumber numberWithFloat:[claimData[@"PlanPaid"] floatValue]]];
    [claimObj setTotalPaid:[NSNumber numberWithFloat:[claimData[@"TotalPrice"] floatValue]]];
    [claimObj setMemberPaid:[NSNumber numberWithFloat:[claimData[@"MemberPaid"] floatValue]]];
    [claimObj setDaysSupply:[NSNumber numberWithInt:[claimData[@"DaysSupply"] intValue]]];
    [claimObj setPrescriberId:claimData[@"PrescriberID"]];
    [claimObj setPrescriberName:claimData[@"PrescriberName"]];
    [claimObj setPharmacyId:claimData[@"PharmacyID"]];
    [claimObj setQuantity:[NSNumber numberWithInt:[claimData[@"Quantity"] intValue]]];
    [claimObj setRxNumber:claimData[@"RxNumber"]];
    [claimObj setFillDate:claimData[@"FillDate"]];
    
    Drugs *drug = [Drugs insertNewDrug:claimData[@"Drug"]];
    [claimObj setDrug:drug];
    [claimObj setUser:[APP_DELEGATE currentUser]];
    
    return claimObj;
    
}
@end
