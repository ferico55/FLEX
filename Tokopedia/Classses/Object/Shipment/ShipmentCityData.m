//
//  ShipmentCityData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentCityData.h"

@implementation ShipmentCityData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"city_id" : @"cityId",
        @"city_name" : @"name",
    };
    [mapping addAttributeMappingsFromDictionary:mappings];
    
    RKRelationshipMapping *districtRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"districts" toKeyPath:@"districts" withMapping:[ShipmentDistrictData mapping]];
    [mapping addPropertyMapping:districtRelationship];

    return mapping;
}

- (NSArray *)districtsName {
    NSMutableArray *districts = [NSMutableArray new];
    for (ShipmentDistrictData *district in _districts) {
        [districts addObject:district.name];
    }
    return districts;
}

@end
