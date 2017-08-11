//
//  NotificationFormNotif.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationFormNotif.h"

@implementation NotificationFormNotif

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"flag_talk_product", @"flag_admin_message", @"flag_message", @"flag_review", @"flag_newsletter"]];
    return mapping;
}

@end
