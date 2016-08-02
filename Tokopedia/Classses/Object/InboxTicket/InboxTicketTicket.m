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

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    
    [mapping addAttributeMappingsFromArray:@[@"ticket_first_message_name]",
                                             @"ticket_create_time",
                                             @"ticket_create_time_fmt",
                                             @"ticket_update_time_fmt",
                                             @"ticket_first_message",
                                             @"ticket_show_reopen_btn",
                                             @"ticket_status",
                                             @"ticket_read_status",
                                             @"ticket_user_label_id",
                                             @"ticket_update_is_cs",
                                             @"ticket_inbox_id",
                                             @"ticket_user_label",
                                             @"ticket_update_by_url",
                                             @"ticket_category",
                                             @"ticket_title",
                                             @"ticket_respond_status",
                                             @"ticket_is_replied",
                                             @"ticket_first_message_image",
                                             @"ticket_url_detail",
                                             @"ticket_update_by_id",
                                             @"ticket_id",
                                             @"ticket_update_by_name",
                                             @"ticket_total_message",
                                             @"ticket_attachment",
                                             @"ticket_invoice_ref_num"]];
    
    return mapping;
}

@end
