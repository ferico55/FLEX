//
//  NotificationFormResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationFormResult.h"

@implementation NotificationFormResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"notification" toKeyPath:@"notification" withMapping:[NotificationFormNotif mapping]]];
    return mapping;
}

@end
