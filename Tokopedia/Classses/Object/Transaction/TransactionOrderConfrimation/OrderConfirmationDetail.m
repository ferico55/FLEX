//
//  OrderConfirmationDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderConfirmationDetail.h"

@implementation OrderConfirmationDetail
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"left_amount",
                      @"status",
                      @"pay_due_date",
                      @"create_time",
                      @"open_amount_before_fee",
                      @"confirmation_id",
                      @"deposit_amount",
                      @"open_amount",
                      @"deposit_amount_plain",
                      @"voucher_amount",
                      @"customer_id",
                      @"payment_type",
                      @"total_item",
                      @"shop_list"
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
