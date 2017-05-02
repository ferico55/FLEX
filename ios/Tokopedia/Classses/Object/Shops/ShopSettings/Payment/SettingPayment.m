//
//  SettingPayment.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingPayment.h"

@implementation SettingPayment

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"message_error", @"message_status", @"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"result" withMapping:[SettingPaymentResult mapping]]];
    return mapping;
}

@end
