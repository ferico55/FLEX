//
//  NewOrderLast.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderLast.h"

@implementation OrderLast
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"last_order_id",
                      @"last_shipment_id",
                      @"last_est_shipping_left",
                      @"last_order_status",
                      @"last_status_date",
                      @"last_pod_code",
                      @"last_pod_desc",
                      @"last_shipping_ref_num",
                      @"last_pod_receiver",
                      @"last_comments",
                      @"last_buyer_status",
                      @"last_status_date_wib",
                      @"last_seller_status"
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
