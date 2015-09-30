//
//  LoyaltyPointMerchant.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LoyaltyPointMerchant.h"

NSString *const TKPMerchantIsLoyalKey = @"is_lucky";
NSString *const TKPMerchantExpTimeKey = @"expire_time";

@implementation LoyaltyPointMerchant

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPMerchantIsLoyalKey, TKPMerchantExpTimeKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
