//
//  InboxTicketResultDetail.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketResultDetail.h"

@implementation InboxTicketResultDetail

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ticket_reply" toKeyPath:@"ticket_reply" withMapping:[InboxTicketReply mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ticket" toKeyPath:@"ticket" withMapping:[InboxTicketTicket mapping]]];
    
    return mapping;
}

@end
