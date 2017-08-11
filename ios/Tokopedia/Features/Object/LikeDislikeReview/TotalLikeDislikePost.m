//
//  TotalLikeDislikePost.m
//  Tokopedia
//
//  Created by Tokopedia on 7/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TotalLikeDislikePost.h"

@implementation TotalLikeDislikePost
+(RKObjectMapping *)mapping{
    RKObjectMapping *totalLikeDislikePostMapping = [RKObjectMapping mappingForClass:[TotalLikeDislikePost class]];
    [totalLikeDislikePostMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"total_like_dislike" toKeyPath:@"total_like_dislike" withMapping:[DetailTotalLikeDislike mapping]]];
    return totalLikeDislikePostMapping;
}
@end
