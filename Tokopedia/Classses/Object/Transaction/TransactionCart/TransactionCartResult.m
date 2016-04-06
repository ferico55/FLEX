//
//  TransactionCartResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartResult.h"

@implementation TransactionCartResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"gateway",
                      @"grand_total",
                      @"grand_total_idr",
                      @"voucher_code",
                      @"deposit_idr",
                      @"not_empty",
                      @"ecash_flag",
                      @"token",
                      @"lp_amount_idr",
                      @"lp_amount",
                      @"cashback_idr",
                      @"cashback",
                      @"grand_total_without_lp_idr",
                      @"grand_total_without_lp"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[TransactionCartList mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relGatewayMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"gateway_list" toKeyPath:@"gateway_list" withMapping:[TransactionCartGateway mapping]];
    [mapping addPropertyMapping:relGatewayMapping];
    
    return mapping;
}

@end
