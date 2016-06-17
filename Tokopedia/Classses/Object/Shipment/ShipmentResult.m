//
//  ShipmentResult.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentResult.h"

@implementation ShipmentResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"message_error",
                      @"message_status",
                      @"status",
                      @"server_process_time"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment" toKeyPath:@"shipment" withMapping:[ShipmentCourier mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
