//
//  InboxTicketUserInvolve.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketUserInvolve.h"

@implementation InboxTicketUserInvolve

- (id)description
{
    return _full_name;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"full_name"]];
    return mapping;
}

@end
