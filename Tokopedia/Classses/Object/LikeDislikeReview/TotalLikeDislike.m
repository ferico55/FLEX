//
//  TotalLikeDislike.m
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TotalLikeDislike.h"

@implementation TotalLikeDislike

+(RKObjectMapping *)mapping{
    RKObjectMapping *totalLikeDislikeMapping = [RKObjectMapping mappingForClass:[TotalLikeDislike class]];
    [totalLikeDislikeMapping addAttributeMappingsFromArray:@[@"like_status", @"review_id"]];
    [totalLikeDislikeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTotalLikeDislike toKeyPath:CTotalLikeDislike withMapping:[DetailTotalLikeDislike mapping]]];
    return totalLikeDislikeMapping;
}
@end
