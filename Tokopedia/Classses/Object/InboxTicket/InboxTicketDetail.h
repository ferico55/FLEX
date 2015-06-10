//
//  InboxTicketDetail.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationViewModel.h"

@interface InboxTicketDetail : NSObject

@property (strong, nonatomic) NSString *ticket_detail_id;
@property (strong, nonatomic) NSString *ticket_detail_create_time_fmt;
@property (strong, nonatomic) NSString *ticket_detail_user_name;
@property (strong, nonatomic) NSString *ticket_detail_new_rating;
@property (strong, nonatomic) NSString *ticket_detail_is_cs;
@property (strong, nonatomic) NSString *ticket_detail_user_url;
@property (strong, nonatomic) NSString *ticket_detail_user_label_id;
@property (strong, nonatomic) NSString *ticket_detail_user_label;
@property (strong, nonatomic) NSString *ticket_detail_user_image;
@property (strong, nonatomic) NSString *ticket_detail_user_id;
@property (strong, nonatomic) NSString *ticket_detail_new_status;
@property (strong, nonatomic) NSString *ticket_detail_message;
@property BOOL *is_just_sent;
@property (strong, nonatomic) NSString *ticket_detail_action;
@property (strong, nonatomic) ConversationViewModel *viewModel;

@end
