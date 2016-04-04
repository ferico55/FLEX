//
//  TxOrderConfirmationListOrder.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmationListOrder.h"

@implementation TxOrderConfirmationListOrder
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_JOB_status",
                      @"order_auto_resi"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shop" toKeyPath:@"order_shop" withMapping:[OrderShop mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shipment" toKeyPath:@"order_shipment" withMapping:[OrderShipment mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_destination" toKeyPath:@"order_destination" withMapping:[OrderDestination mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_detail" toKeyPath:@"order_detail" withMapping:[OrderDetail mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"order_products" toKeyPath:@"order_products" withMapping:[OrderProduct mapping]];
    [mapping addPropertyMapping:relMapping];

    return mapping;
}

@end
