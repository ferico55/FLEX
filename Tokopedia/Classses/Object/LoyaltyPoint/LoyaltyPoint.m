//
//  LoyaltyPoint.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LoyaltyPoint.h"

NSString *const TKPStatusKey = @"status";
NSString *const TKPServerKey = @"server_process_time";
NSString *const TKPResultKey = @"result";

@implementation LoyaltyPoint

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPServerKey, TKPStatusKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPResultKey toKeyPath:TKPResultKey withMapping:[LoyaltyPointResult mapping]]];
    return mapping;
}

@end
