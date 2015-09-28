//
//  LoyaltyPointDetail.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LoyaltyPointDetail.h"

NSString *const TKPIsExpKey = @"is_expired";
NSString *const TKPHasLPKey = @"has_lp";
NSString *const TKPAmountKey = @"amount";
NSString *const TKPLPExpTimeKey = @"expire_time";

@implementation LoyaltyPointDetail

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPIsExpKey,TKPHasLPKey,TKPAmountKey,TKPLPExpTimeKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
