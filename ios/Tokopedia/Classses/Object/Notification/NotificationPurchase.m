//
//  NotificationPurchase.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationPurchase.h"

@implementation NotificationPurchase

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"purchase_reorder", @"purchase_payment_confirm", @"purchase_payment_conf", @"purchase_order_status", @"purchase_delivery_confirm"]];
    return mapping;
}

@end
