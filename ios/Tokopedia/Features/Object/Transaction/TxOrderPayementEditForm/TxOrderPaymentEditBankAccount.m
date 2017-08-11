//
//  TxOrderPaymentEditBankAccount.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentEditBankAccount.h"

@implementation TxOrderPaymentEditBankAccount
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"bank_account_id_chosen"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"bank_account_list" toKeyPath:@"bank_account_list" withMapping:[BankAccountFormList mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
