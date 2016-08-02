//
//  InboxTicketTicket.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketTicket.h"

@implementation InboxTicketTicket

- (NSString *)ticket_category {
    return [_ticket_category kv_decodeHTMLCharacterEntities];
}

@end
