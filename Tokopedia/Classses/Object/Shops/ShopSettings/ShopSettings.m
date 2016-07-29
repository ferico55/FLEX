//
//  ShopSettings.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopSettings.h"

@implementation ShopSettings
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [mapping addAttributeMappingsFromArray:@[@"message_error", @"status", @"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[ShopSettingsResult mapping]]];
    return mapping;
}
@end
