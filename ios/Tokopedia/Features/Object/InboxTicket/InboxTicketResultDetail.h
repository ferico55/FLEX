//
//  InboxTicketResultDetail.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxTicketReply.h"
#import "InboxTicketTicket.h"

@interface InboxTicketResultDetail : NSObject <TKPObjectMapping>

@property (strong, nonatomic) InboxTicketReply *ticket_reply;
@property (strong, nonatomic) InboxTicketTicket *ticket;

@end
