//
//  TransactionCalculatePriceResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCalculatePriceResult.h"

@implementation TransactionCalculatePriceResult

-(NSArray<ShippingInfoShipments *> *)shipment{
    return _shipment?:@[];
}

-(NSArray<NSString *> *)auto_resi{
    return _auto_resi?:@[];
}

+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product" toKeyPath:@"product" withMapping:[ProductDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"rpx" toKeyPath:@"rpx" withMapping:[RPX mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment" toKeyPath:@"shipment" withMapping:[ShippingInfoShipments mapping]];
    [mapping addPropertyMapping:relMapping];

    return mapping;
}

@end
