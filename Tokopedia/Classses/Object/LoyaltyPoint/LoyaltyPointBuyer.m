//
//  LoyaltyPointBuyer.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LoyaltyPointBuyer.h"

NSString *const TKPBuyerIsLoyalKey = @"is_lucky";
NSString *const TKPBuyerExpTimeKey = @"expire_time";

@implementation LoyaltyPointBuyer

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPBuyerIsLoyalKey,TKPBuyerExpTimeKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
