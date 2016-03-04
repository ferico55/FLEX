//
//  InboxMessageAction.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageAction.h"

@implementation InboxMessageAction

+ (RKObjectMapping *)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxMessageAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status": @"status",
                                                        @"message_error": @"message_error",
                                                        @"server_process_time": @"server_process_time"}];

    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[InboxMessageActionResult mapping]];
    [statusMapping addPropertyMapping:resulRel];
    return statusMapping;
}
@end
