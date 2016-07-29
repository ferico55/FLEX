//
//  NewOrderCustomer.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderCustomer.h"

@implementation OrderCustomer

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"customer_url", @"customer_id", @"customer_name", @"customer_image"]];
    return mapping;
}

@end
