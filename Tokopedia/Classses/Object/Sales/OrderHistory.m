//
//  NewOrderHistory.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderHistory.h"

@implementation OrderHistory

- (NSString *)history_comments {
    if ([_history_comments isEqualToString:@"0"]) {
        _history_comments = @"";
    }
    return [_history_comments stringByReplacingOccurrencesOfString:@"            " withString:@""];
}
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"history_status_date",
                      @"history_status_date_full",
                      @"history_order_status",
                      @"history_comments",
                      @"history_action_by",
                      @"history_buyer_status",
                      @"history_seller_status"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
