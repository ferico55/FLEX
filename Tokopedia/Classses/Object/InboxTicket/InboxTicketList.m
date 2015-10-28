//
//  InboxTicketList.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketList.h"

@implementation InboxTicketList

- (NSString *)ticket_title {
    return [_ticket_title kv_decodeHTMLCharacterEntities];
}

- (NSString *)ticket_category {
    return [_ticket_category kv_decodeHTMLCharacterEntities];
}

@end
