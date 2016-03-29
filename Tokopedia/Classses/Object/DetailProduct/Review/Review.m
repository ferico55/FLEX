//
//  Review.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Review.h"

@implementation Review

+ (RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time", @"message_error"]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[ReviewResult mapping]]];
    return statusMapping;
}

@end
