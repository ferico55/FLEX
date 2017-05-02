//
//  NewOrderPayment.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderPayment.h"

@implementation OrderPayment

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"payment_process_due_date", @"payment_komisi", @"payment_verify_date", @"payment_shipping_due_date", @"payment_process_day_left", @"payment_gateway_id", @"payment_gateway_image", @"payment_shipping_day_left", @"payment_gateway_name"]];
    return mapping;
}

@end
