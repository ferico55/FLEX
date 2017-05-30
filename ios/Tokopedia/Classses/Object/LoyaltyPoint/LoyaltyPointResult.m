//
//  LoyaltyPointResult.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LoyaltyPointResult.h"

NSString *const TKPMerchantKey = @"merchant";
NSString *const TKPDetailKey = @"loyalty_point";
NSString *const TKPBuyerKey = @"buyer";

@implementation LoyaltyPointResult

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"uri", @"active"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPMerchantKey toKeyPath:TKPMerchantKey withMapping:[LoyaltyPointMerchant mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPDetailKey toKeyPath:TKPDetailKey withMapping:[LoyaltyPointDetail mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPBuyerKey toKeyPath:TKPBuyerKey withMapping:[LoyaltyPointBuyer mapping]]];
    return mapping;
}

@end
