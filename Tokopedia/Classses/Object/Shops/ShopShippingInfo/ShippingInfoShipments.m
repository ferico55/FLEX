//
//  ShippingInfoShipments.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShippingInfoShipments.h"

@implementation ShippingInfoShipments
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"shipment_id",
                      @"shipment_name",
                      @"shipment_image",
                      @"shipment_available",
                      @"shipment_package_id",
                      @"shipment_package_name",
                      @"auto_resi_image"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment_package" toKeyPath:@"shipment_package" withMapping:[ShippingInfoShipmentPackage mapping]];
    [mapping addPropertyMapping:relMapping];
    
    return mapping;
}
@end
