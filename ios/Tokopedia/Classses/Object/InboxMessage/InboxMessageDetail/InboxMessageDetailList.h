//
//  InboxMessageDetailList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxMessageReplyTime.h"

@interface InboxMessageDetailList : NSObject



@property (nonatomic, strong, nonnull) NSString *message_action;
@property (nonatomic, strong, nonnull) NSString *message_create_by;
@property (nonatomic, strong, nonnull) NSString *message_reply;
@property (nonatomic, strong, nonnull) InboxMessageReplyTime *message_reply_time;
@property (nonatomic, strong, nonnull) NSString *message_reply_id;
@property (nonatomic, strong, nonnull) NSString *message_button_spam;
@property (nonatomic, strong, nonnull) NSString *message_reply_time_fmt;
@property (nonatomic, strong, nonnull) NSString *message_create_time_fmt;
@property (nonatomic, strong, nonnull) NSString *message_reply_time_ago;
@property (nonatomic, strong, nonnull) NSString *is_moderator;
@property (nonatomic, strong, nonnull) NSString *user_id;
@property (nonatomic, strong, nonnull) NSString *user_name;
@property (nonatomic, strong, nonnull) NSString *user_image;
@property (nonatomic, strong, nonnull) NSString *is_not_delivered;
@property (nonatomic, strong, nonnull) NSString *user_label;
@property (nonatomic, strong, nonnull) NSString *user_label_id;

@property (nonatomic) BOOL is_just_sent;

+ (RKObjectMapping*)mapping;

@end
