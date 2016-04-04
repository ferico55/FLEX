//
//  LikeDislikePost.m
//  Tokopedia
//
//  Created by Tokopedia on 7/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "LikeDislikePost.h"

@implementation LikeDislikePost : NSObject 
+(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[LikeDislikePost class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time", @"message_error"]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[LikeDislikePostResult mapping]]];
    return statusMapping;
}
@end
