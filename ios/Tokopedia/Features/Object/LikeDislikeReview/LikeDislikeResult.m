//
//  LikeDislikeResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LikeDislikeResult.h"

@implementation LikeDislikeResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LikeDislikeResult class]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"like_dislike_review" toKeyPath:@"like_dislike_review" withMapping:[TotalLikeDislike mapping]]];
    return resultMapping;
}
@end
