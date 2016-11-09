//
//  InboxTicketReply.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InboxTicketDetail.h"

@interface InboxTicketReply : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSArray <InboxTicketDetail*>*ticket_reply_data;
@property (strong, nonatomic) NSString *ticket_reply_total_data;
@property (strong, nonatomic) NSString *ticket_reply_total_page;

@end
