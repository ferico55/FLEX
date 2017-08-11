//
//  ShipmentShopData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentShopData.h"
#import "Tokopedia-Swift.h"

@implementation ShipmentShopData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"city_id" : @"cityId",
        @"shipping_id" : @"shippingId",
        @"city_name" : @"cityName",
        @"addr_street" : @"address",
        @"province_name" : @"provinceName",
        @"district_name" : @"districtName",
        @"province_id" : @"provinceId",
        @"postal_code" : @"postalCode",
        @"district_id" : @"districtId",
        @"origin" : @"origin",
        @"longitude" : @"longitude",
        @"latitude" : @"latitude",
    };
    [mapping addAttributeMappingsFromDictionary:mappings];
    return mapping;
}

- (NSString *)streetNameFromAddress:(GMSAddress *)address {
    NSString *street = @"Tentukan Peta Lokasi";
    TKPAddressStreet *addressStreet = [TKPAddressStreet new];
    street = [addressStreet getStreetAddress:address.thoroughfare];
    return street;
}

@end
