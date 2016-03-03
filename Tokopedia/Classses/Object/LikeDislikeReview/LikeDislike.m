//
//  LikeDislike.m
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LikeDislike.h"

@implementation LikeDislike
+(RKObjectMapping *)mapping{
    RKObjectMapping *likeDislikeMapping = [RKObjectMapping mappingForClass:[LikeDislike class]];
    [likeDislikeMapping addAttributeMappingsFromArray:@[@"status", @"config", @"server_process_time"]];
    [likeDislikeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"result" withMapping:[LikeDislikeResult mapping]]];
    return likeDislikeMapping;
}
@end
