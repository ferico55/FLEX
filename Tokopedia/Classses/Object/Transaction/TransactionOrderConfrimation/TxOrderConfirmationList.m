//
//  TxOrderConfirmationList.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmationList.h"

@implementation TxOrderConfirmationList
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"total_extra_fee_plain",
                      @"total_extra_fee"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"confirmation" toKeyPath:@"confirmation" withMapping:[OrderConfirmationDetail mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"order_list" toKeyPath:@"order_list" withMapping:[TxOrderConfirmationListOrder mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relMappingFee = [RKRelationshipMapping relationshipMappingFromKeyPath:@"extra_fee" toKeyPath:@"extra_fee" withMapping:[OrderExtraFee mapping]];
    [mapping addPropertyMapping:relMappingFee];
    
    return mapping;
}

@end
