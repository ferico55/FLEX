//
//  TxOrderPaymentEditSystemBank.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentEditSystemBank.h"

@implementation TxOrderPaymentEditSystemBank
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"sysbank_id_chosen"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"sysbank_list" toKeyPath:@"sysbank_list" withMapping:[SystemBankAcount mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
