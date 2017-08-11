//
//  LikeDislikePostResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LikeDislikePostResult.h"

@implementation LikeDislikePostResult

+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LikeDislikePostResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"is_success"]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"content" toKeyPath:@"content" withMapping:[TotalLikeDislikePost mapping]]];
    return resultMapping;
}

@end
