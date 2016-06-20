//
//  NotificationResult.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationResult.h"

@implementation NotificationResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"total_cart", @"resolution", @"incr_notif", @"total_notif"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"sales" toKeyPath:@"sales" withMapping:[NotificationSales mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"purchase" toKeyPath:@"purchase" withMapping:[NotificationPurchase mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"inbox" toKeyPath:@"inbox" withMapping:[NotificationInbox mapping]]];
    return mapping;
}

@end
