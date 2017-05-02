//
//  TxOrderConfirmPaymentFormForm.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxOrderConfirmPaymentFormForm.h"

@implementation TxOrderConfirmPaymentFormForm
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"token"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order" toKeyPath:@"order" withMapping:[OrderDetailForm mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"bank_account" toKeyPath:@"bank_account" withMapping:[BankAccountFormList mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relSysBankMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"sysbank_account" toKeyPath:@"sysbank_account" withMapping:[SystemBankAcount mapping]];
    [mapping addPropertyMapping:relSysBankMapping];
    
    RKRelationshipMapping *relMethodMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"method" toKeyPath:@"method" withMapping:[MethodList mapping]];
    [mapping addPropertyMapping:relMethodMapping];
    
    return mapping;
}

@end
