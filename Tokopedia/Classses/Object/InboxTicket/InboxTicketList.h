//
//  InboxTicketList.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxTicketList : NSObject

@property (strong, nonatomic) NSString *ticket_create_time_fmt2;
@property (strong, nonatomic) NSString *ticket_first_message_name;
@property (strong, nonatomic) NSString *ticket_update_time_fmt2;
@property (strong, nonatomic) NSString *ticket_create_time_fmt;
@property (strong, nonatomic) NSString *ticket_update_time_fmt;
@property (strong, nonatomic) NSString *ticket_status;
@property (strong, nonatomic) NSString *ticket_read_status;
@property (strong, nonatomic) NSString *ticket_update_is_cs;
@property (strong, nonatomic) NSString *ticket_inbox_id;
@property (strong, nonatomic) NSString *ticket_update_by_url;
@property (strong, nonatomic) NSString *ticket_category;
@property (strong, nonatomic) NSString *ticket_title;
@property (strong, nonatomic) NSString *ticket_total_message;
@property (strong, nonatomic) NSString *ticket_show_more;
@property (strong, nonatomic) NSString *ticket_show_reopen_btn;
@property (strong, nonatomic) NSString *ticket_respond_status;
@property (strong, nonatomic) NSString *ticket_is_replied;
@property (strong, nonatomic) NSString *ticket_url_detail;
@property (strong, nonatomic) NSArray *ticket_user_involve;
@property (strong, nonatomic) NSString *ticket_update_by_id;
@property (strong, nonatomic) NSString *ticket_id;
@property (strong, nonatomic) NSString *ticket_update_by_name;

@end
