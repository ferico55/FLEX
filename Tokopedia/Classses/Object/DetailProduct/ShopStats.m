//
//  ShopStats.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopStats.h"

@implementation ShopStats

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"shop_service_rate",
                      @"shop_service_description",
                      @"shop_speed_rate",
                      @"shop_accuracy_rate",
                      @"shop_accuracy_description",
                      @"shop_speed_description",
                      @"shop_total_transaction",
                      @"shop_total_etalase",
                      @"shop_total_product",
                      @"shop_item_sold",
                      @"tx_count_success",
                      @"hide_rate",
                      @"tx_count",
                      @"rate_failure",
                      @"shop_total_transaction_canceled",
                      @"shop_reputation_score",
                      @"rate_success",
                      @"tooltip"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_badge_level"
                                                                           toKeyPath:@"shop_badge_level"
                                                                          withMapping:[ShopBadgeLevel mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_last_one_month"
                                                                            toKeyPath:@"shop_last_one_month"
                                                                          withMapping:[CountRatingResult mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_last_six_months"
                                                                            toKeyPath:@"shop_last_six_months"
                                                                          withMapping:[CountRatingResult mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_last_twelve_months"
                                                                            toKeyPath:@"shop_last_twelve_months"
                                                                          withMapping:[CountRatingResult mapping]]];
    
    return mapping;
}

- (NSString *)pointsText {
    NSInteger score = self.shop_reputation_score.integerValue;
    NSString *text = score == 0? @"Belum ada nilai reputasi": [NSString stringWithFormat:@"%@ poin", score];
    return text;
}


@end
