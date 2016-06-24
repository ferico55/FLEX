//
//  ShipmentCourier.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentCourier.h"
#import "ShipmentCourierPackage.h"

@implementation ShipmentCourier

- (id)description
{
    return _shipment_name;
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"shipment_id",
                      @"shipment_name",
                      @"shipment_available",
                      @"shipment_image"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment_package" toKeyPath:@"shipment_package" withMapping:[ShipmentCourierPackage mapping]]];
    return mapping;
}

@end
