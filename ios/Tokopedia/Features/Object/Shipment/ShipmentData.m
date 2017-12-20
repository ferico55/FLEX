//
//  ShipmentData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentData.h"
#import "Tokopedia-Swift.h"

@implementation ShipmentData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"loc"]];
    
    RKRelationshipMapping *dataRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_shipping" toKeyPath:@"shop" withMapping:[ShipmentShopData mapping]];
    [mapping addPropertyMapping:dataRelationship];
    
    RKRelationshipMapping *keroToken = [RKRelationshipMapping relationshipMappingFromKeyPath:@"token" toKeyPath:@"token" withMapping:[ShipmentKeroToken mapping]];
    [mapping addPropertyMapping:keroToken];

    RKRelationshipMapping *courierRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"courier" toKeyPath:@"courier" withMapping:[ShipmentCourierData mapping]];
    [mapping addPropertyMapping:courierRelationship];

    RKRelationshipMapping *provinceRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"provinces_cities_districts" toKeyPath:@"provinces" withMapping:[ShipmentProvinceData mapping]];
    [mapping addPropertyMapping:provinceRelationship];

    RKRelationshipMapping *paymentOptionsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"payment_options" toKeyPath:@"paymentOptions" withMapping:[Payment mapping]];
    [mapping addPropertyMapping:paymentOptionsMapping];
    
    return mapping;
}

- (NSArray *)provincesName {
    NSMutableArray *provinces = [NSMutableArray new];
    for (ShipmentProvinceData *province in _provinces) {
        [provinces addObject:province.name];
    }
    return provinces;
}

@end
