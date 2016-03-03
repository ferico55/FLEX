//
//  ShopReputation.m
//  Tokopedia
//
//  Created by Tokopedia on 7/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopReputation.h"
#import "ShopBadgeLevel.h"

@implementation ShopReputation

+ (RKObjectMapping *)mapping{
    RKObjectMapping *shopReputationMapping = [RKObjectMapping mappingForClass:[ShopReputation class]];
    [shopReputationMapping addAttributeMappingsFromArray:@[@"tooltip",
                                                           @"reputation_badge",
                                                           @"reputation_score",
                                                           @"score",
                                                           @"min_badge_score"]];
    [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reputation_badge" toKeyPath:@"reputation_badge_object" withMapping:[ShopBadgeLevel mapping]]];
    return shopReputationMapping;
}
@end
