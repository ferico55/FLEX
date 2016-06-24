//
//  Notification.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"result" withMapping:[NotificationResult mapping]]];
    return mapping;
}

+ (RKResponseDescriptor *)responseDescriptor {
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self mapping]
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:@"/v4/notification/get_notification.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:statusCodes];
    return responseDescriptor;
}

@end
