//
//  InboxMessageDetailList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxMessageDetailList : NSObject

@property (nonatomic, strong) NSString *message_action;
@property (nonatomic, strong) NSString *message_create_by;
@property (nonatomic, strong) NSString *message_reply;
@property (nonatomic, strong) NSString *message_reply_id;
@property (nonatomic, strong) NSString *message_button_spam;
@property (nonatomic, strong) NSString *message_reply_time_fmt;
@property (nonatomic, strong) NSString *message_reply_time_ago;
@property (nonatomic, strong) NSString *is_moderator;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *user_image;
@property (nonatomic, strong) NSString *is_not_delivered;
@property (nonatomic, strong) NSString *user_label;
@property (nonatomic, strong) NSString *user_label_id;
@property (nonatomic) BOOL is_just_sent;

+ (RKObjectMapping*)mapping;

@end
