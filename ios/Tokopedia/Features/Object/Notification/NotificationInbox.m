//
//  NotificationInbox.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationInbox.h"

@implementation NotificationInbox

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"inbox_reputation", @"inbox_friend", @"inbox_wishlist", @"inbox_ticket", @"inbox_review", @"inbox_message", @"inbox_talk"]];
    return mapping;
}

@end
