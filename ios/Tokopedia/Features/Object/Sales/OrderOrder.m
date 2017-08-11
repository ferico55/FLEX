//
//  NewOrderOrder.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderOrder.h"

@implementation OrderOrder

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"is_allow_manage_tx", @"shop_name", @"is_gold_shop"]];
    return mapping;
}

@end
