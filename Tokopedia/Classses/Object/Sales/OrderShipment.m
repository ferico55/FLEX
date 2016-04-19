//
//  NewOrderShipment.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderShipment.h"

@implementation OrderShipment
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"shipment_logo",
                      @"shipment_package_id",
                      @"shipment_id",
                      @"shipment_product",
                      @"shipment_name"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
