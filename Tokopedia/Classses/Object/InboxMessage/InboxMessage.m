//
//  InboxMessage.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessage.h"

@implementation InboxMessage

+ (RKObjectMapping *)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:self];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status":@"status",
                                                        @"server_process_time":@"server_process_time"}];
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"result" withMapping:[InboxMessageResult mapping]];
    [statusMapping addPropertyMapping:resulRel];
    
    return statusMapping;
}

@end
