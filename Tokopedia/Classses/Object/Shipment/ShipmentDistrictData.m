//
//  ShipmentDistrictData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentDistrictData.h"

@implementation ShipmentDistrictData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"district_id" : @"districtId",
        @"district_name" : @"name",
    };
    [mapping addAttributeMappingsFromDictionary:mappings];
    return mapping;
}

- (NSString *)name {
    if ([_name isEqualToString:@""]) {
        return @"Pilih Distrik";
    } else {
        return _name;
    }
}

@end
