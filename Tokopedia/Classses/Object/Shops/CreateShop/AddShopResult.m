//
//  AddShopResult.m
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AddShopResult.h"

@implementation AddShopResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"is_success", @"status_domain", @"shop_id", @"shop_url", @"post_key"]];
    return mapping;
}

@end
