//
//  AddShop.m
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AddShop.h"

@implementation AddShop

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"message_error", @"message_status", @"status", @"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[AddShopResult mapping]]];
    return mapping;
}

@end
