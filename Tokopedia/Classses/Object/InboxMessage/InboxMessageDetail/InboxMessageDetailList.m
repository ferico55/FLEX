//
//  InboxMessageDetailList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailList.h"
#import "inbox.h"

@implementation InboxMessageDetailList

- (NSString*)message_reply {
    return [_message_reply kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:self];
    [listMapping addAttributeMappingsFromArray:@[
                                                 @"message_action",
                                                 @"message_create_by",
                                                 @"message_reply",
                                                 @"message_reply_id",
                                                 @"message_button_spam",
                                                 @"message_reply_time_fmt",
                                                 @"is_moderator",
                                                 @"user_id",
                                                 @"user_name",
                                                 @"user_image",
                                                 @"user_label",
                                                 @"user_label_id"
                                                 ]];
    
    return listMapping;
}

@end
