//
//  InboxMessageList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxMessageList : NSObject

@property (nonatomic, strong) NSString *message_id;
@property (nonatomic, strong) NSString *user_full_name;
@property (nonatomic, strong) NSString *message_create_time;
@property (nonatomic, strong) NSString *message_read_status;
@property (nonatomic, strong) NSString *message_title;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *message_reply;
@property (nonatomic, strong) NSString *message_inbox_id;
@property (nonatomic, strong) NSString *user_image;

@end
