//
//  InboxMessageDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetail.h"

@implementation InboxMessageDetail

+ (RKObjectMapping *)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:self];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status":@"status",
                                                        @"server_process_time":@"server_process_time"}];
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"result" withMapping:[InboxMessageDetailResult mapping]];
    [statusMapping addPropertyMapping:resulRel];
    
    return statusMapping;
}

@end
