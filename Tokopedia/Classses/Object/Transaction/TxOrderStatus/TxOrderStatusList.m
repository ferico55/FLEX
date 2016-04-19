//
//  TxOrderStatusList.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderStatusList.h"

@implementation TxOrderStatusList
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_JOB_status",
                      @"order_auto_resi",
                      @"order_auto_awb",
                      @"order_JOB_detail"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_detail" toKeyPath:@"order_detail" withMapping:[OrderDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_deadline" toKeyPath:@"order_deadline" withMapping:[OrderDeadline mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_button" toKeyPath:@"order_button" withMapping:[OrderButton mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"order_products" toKeyPath:@"order_products" withMapping:[OrderProduct mapping]];
    [mapping addPropertyMapping:relMapping];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shop" toKeyPath:@"order_shop" withMapping:[OrderShop mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shipment" toKeyPath:@"order_shipment" withMapping:[OrderShipment mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_last" toKeyPath:@"order_last" withMapping:[OrderLast mapping]]];
    RKRelationshipMapping *relHistoryMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"order_history" toKeyPath:@"order_history" withMapping:[OrderHistory mapping]];
    [mapping addPropertyMapping:relHistoryMapping];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_destination" toKeyPath:@"order_destination" withMapping:[OrderDestination mapping]]];
    return mapping;
}

@end
