//
//  ShopStats.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopStats.h"

@implementation ShopStats
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [mapping addAttributeMappingsFromArray:@[@"shop_service_rate",
                                             @"shop_speed_rate",
                                             @"shop_accuracy_rate",
                                             @"shop_service_description",
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
                                             ]];
    
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
@end
