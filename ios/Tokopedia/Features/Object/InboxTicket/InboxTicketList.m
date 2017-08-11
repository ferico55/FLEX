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

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"ticket_create_time_fmt2",
                      @"ticket_first_message_name",
                      @"ticket_update_time_fmt2",
                      @"ticket_create_time_fmt",
                      @"ticket_update_time_fmt",
                      @"ticket_status",
                      @"ticket_read_status",
                      @"ticket_update_is_cs",
                      @"ticket_inbox_id",
                      @"ticket_update_by_url",
                      @"ticket_category",
                      @"ticket_title",
                      @"ticket_total_message",
                      @"ticket_show_more",
                      @"ticket_show_reopen_btn",
                      @"ticket_respond_status",
                      @"ticket_is_replied",
                      @"ticket_url_detail",
                      @"ticket_update_by_id",
                      @"ticket_id",
                      @"ticket_update_by_name",
                      @"ticket_category_id"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"ticket_user_involve" toKeyPath:@"ticket_user_involve" withMapping:[InboxTicketUserInvolve mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
