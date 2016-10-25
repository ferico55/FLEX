//
//  InboxTicketDetailAttachment.m
//  Tokopedia
//
//  Created by Tokopedia on 6/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketDetailAttachment.h"

@implementation InboxTicketDetailAttachment

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"img_src",
                                             @"img_link"]
     ];
    return mapping;
}

@end
