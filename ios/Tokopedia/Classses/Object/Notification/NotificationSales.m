//
//  NotificationSales.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationSales.h"

@implementation NotificationSales

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"sales_new_order", @"sales_shipping_confirm", @"sales_shipping_status"]];
    return mapping;
}

@end
