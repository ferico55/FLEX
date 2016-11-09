//
//  InboxTicketTicket.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxTicketDetailAttachment.h"

@interface InboxTicketTicket : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *ticket_first_message_name;
@property (strong, nonatomic) NSString *ticket_create_time;
@property (strong, nonatomic) NSString *ticket_create_time_fmt;
@property (strong, nonatomic) NSString *ticket_update_time_fmt;
@property (strong, nonatomic) NSString *ticket_first_message;
@property (strong, nonatomic) NSString *ticket_show_reopen_btn;
@property (strong, nonatomic) NSString *ticket_status;
@property (strong, nonatomic) NSString *ticket_read_status;
@property (strong, nonatomic) NSString *ticket_user_label_id;
@property (strong, nonatomic) NSString *ticket_update_is_cs;
@property (strong, nonatomic) NSString *ticket_inbox_id;
@property (strong, nonatomic) NSString *ticket_user_label;
@property (strong, nonatomic) NSString *ticket_update_by_url;
@property (strong, nonatomic) NSString *ticket_category;
@property (strong, nonatomic) NSString *ticket_title;
@property (strong, nonatomic) NSString *ticket_respond_status;
@property (strong, nonatomic) NSString *ticket_is_replied;
@property (strong, nonatomic) NSString *ticket_first_message_image;
@property (strong, nonatomic) NSString *ticket_url_detail;
@property (strong, nonatomic) NSString *ticket_update_by_id;
@property (strong, nonatomic) NSString *ticket_id;
@property (strong, nonatomic) NSString *ticket_update_by_name;
@property (strong, nonatomic) NSString *ticket_total_message;
@property (strong, nonatomic) NSArray <InboxTicketDetailAttachment*>*ticket_attachment;
@property (strong, nonatomic) NSString *ticket_invoice_ref_num;

@end
