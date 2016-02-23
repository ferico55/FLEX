//
//  ShopReputation.m
//  Tokopedia
//
//  Created by Tokopedia on 7/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopReputation.h"


@implementation ShopReputation

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"tooltip",
                      @"reputation_score",
                      @"score",
                      @"min_badge_score"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reputation_badge_object" toKeyPath:@"reputation_badge_object" withMapping:[ShopBadgeLevel mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reputation_badge" toKeyPath:@"reputation_badge" withMapping:[ShopBadgeLevel mapping]]];
    return mapping;
}

@end
