//
//  TransactionCartResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartResult.h"

#import "Tokopedia-Swift.h"

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
                      @"grand_total_without_lp",
                      @"is_coupon_active"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addAttributeMappingsFromDictionary:@{@"token_kero": @"keroToken", @"ut": @"ut"}];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[TransactionCartList mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relGatewayMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"gateway_list" toKeyPath:@"gateway_list" withMapping:[TransactionCartGateway mapping]];
    [mapping addPropertyMapping:relGatewayMapping];
    
    RKRelationshipMapping *donationGatewayMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"donation" toKeyPath:@"donation" withMapping:[Donation mapping]];
    [mapping addPropertyMapping:donationGatewayMapping];
    
    RKRelationshipMapping *promoSuggestionGatewayMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"promo_suggestion" toKeyPath:@"promoSuggestion" withMapping:[PromoSuggestion mapping]];
    [mapping addPropertyMapping:promoSuggestionGatewayMapping];
    
    return mapping;
}

@end
