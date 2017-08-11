//
//  InboxTicketReply.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketReply.h"

@implementation InboxTicketReply
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"ticket_reply_total_data",
                      @"ticket_reply_total_page"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"ticket_reply_total_data",
                                             @"ticket_reply_total_page"]
     ];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ticket_reply_data" toKeyPath:@"ticket_reply_data" withMapping:[InboxTicketDetail mapping]]
     ];
    return mapping;
}

@end
