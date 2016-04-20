//
//  ShopSettingsResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopSettingsResult.h"

@implementation ShopSettingsResult

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"is_success", @"etalase_id"]];
    return mapping;
}

@end
