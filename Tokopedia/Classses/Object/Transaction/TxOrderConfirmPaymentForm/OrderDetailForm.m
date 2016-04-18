//
//  Order.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderDetailForm.h"

@implementation OrderDetailForm
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_left_amount_idr",
                      @"order_deposit_used_idr",
                      @"order_invoice",
                      @"order_confirmation_code_idr",
                      @"order_grand_total_idr",
                      @"order_left_amount",
                      @"order_confirmation_code",
                      @"order_deposit_used",
                      @"order_depositable",
                      @"order_grand_total",
                      @"order_payment_amount",
                      @"order_payment_month",
                      @"order_payment_day",
                      @"order_payment_year"
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
