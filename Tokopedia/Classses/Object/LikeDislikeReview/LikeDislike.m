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
    [likeDislikeMapping addAttributeMappingsFromArray:@[@"status", @"message_error", @"server_process_time"]];
    [likeDislikeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CLResult toKeyPath:CLResult withMapping:[LikeDislikeResult mapping]]];
    return likeDislikeMapping;
}
@end
