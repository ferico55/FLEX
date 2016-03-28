//
//  InboxMessageList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageList.h"

@implementation InboxMessageList

+ (RKObjectMapping *)mapping {
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:self];
    [listMapping addAttributeMappingsFromArray:@[
                                                 @"message_id",
                                                 @"user_full_name",
                                                 @"message_create_time",
                                                 @"message_read_status",
                                                 @"message_title",
                                                 @"user_id",
                                                 @"message_reply",
                                                 @"message_inbox_id",
                                                 @"user_image",
                                                 @"json_data_info",
                                                 @"user_label",
                                                 @"user_label_id"
                                                 ]];
    
    RKRelationshipMapping *userReputationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"user_reputation" toKeyPath:@"user_reputation" withMapping:[ReputationDetail mapping]];
    [listMapping addPropertyMapping:userReputationRel];
    
    return listMapping;
}

@end
