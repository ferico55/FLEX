//
//  TrackOrder.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrder.h"

@implementation TrackOrder

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"change",
                      @"status",
                      @"no_history",
                      @"receiver_name",
                      @"order_status",
                      @"shipping_ref_num",
                      @"invalid",
                      @"delivered"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"detail" toKeyPath:@"detail" withMapping:[TrackOrderDetail mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relHistoryMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"track_history" toKeyPath:@"track_history" withMapping:[TrackOrderHistory mapping]];
    [mapping addPropertyMapping:relHistoryMapping];
    return mapping;
}

@end
