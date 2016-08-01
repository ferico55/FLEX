//
//  InboxTicketPaging.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketPaging.h"

@implementation InboxTicketPaging

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromArray:@[@"uri_previous", @"uri_next"]];

    return mapping;
}

@end
