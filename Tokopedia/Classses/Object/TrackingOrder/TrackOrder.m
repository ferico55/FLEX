//
//  TrackOrder.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrder.h"

@implementation TrackOrder

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"change", @"status", @"no_history", @"receiver_name", @"order_status", @"shipping_ref_num", @"invalid", @"delivered"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"detail" toKeyPath:@"detail" withMapping:[TrackOrderDetail mapping]]];
    RKRelationshipMapping *rel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"track_history" toKeyPath:@"track_history" withMapping:[TrackOrderHistory mapping]];
    [mapping addPropertyMapping:rel];
    return mapping;
}

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}

@end
