//
//  ReplyInboxTicketResult.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReplyInboxTicketResult.h"

@implementation ReplyInboxTicketResult
+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"is_success",
                                             @"post_key",
                                             @"file_uploaded"]
     ];
    return mapping;
}

@end
