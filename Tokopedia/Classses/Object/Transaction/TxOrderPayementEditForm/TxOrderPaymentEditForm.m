//
//  TxOrderPaymentEditForm.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentEditForm.h"

@implementation TxOrderPaymentEditForm
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
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"bank_account" toKeyPath:@"bank_account" withMapping:[TxOrderPaymentEditBankAccount mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"sysbank_account" toKeyPath:@"sysbank_account" withMapping:[TxOrderPaymentEditSystemBank mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"method" toKeyPath:@"method" withMapping:[TxOrderPaymentEditMethod mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"payment" toKeyPath:@"payment" withMapping:[OrderDetailForm mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order" toKeyPath:@"order" withMapping:[TxOrderPaymentEditOrder mapping]]];
    return mapping;
}

@end
