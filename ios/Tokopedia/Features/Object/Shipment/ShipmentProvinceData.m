//
//  ShipmentProvinceData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentProvinceData.h"

@implementation ShipmentProvinceData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"province_id" : @"provinceId",
        @"province_name" : @"name",
    };
    [mapping addAttributeMappingsFromDictionary:mappings];
    
    RKRelationshipMapping *cityRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"cities" toKeyPath:@"cities" withMapping:[ShipmentCityData mapping]];
    [mapping addPropertyMapping:cityRelationship];

    return mapping;
}

- (NSArray *)citiesName {
    NSMutableArray *cities = [NSMutableArray new];
    for (ShipmentCityData *city in _cities) {
        [cities addObject:city.name];
    }
    return cities;
}

@end
