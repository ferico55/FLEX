//
//  ShopSettingsResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopSettingsResult.h"

@implementation ShopSettingsResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [mapping addAttributeMappingsFromArray:@[@"is_success", @"etalase_id"]];
    return mapping;
}
@end
