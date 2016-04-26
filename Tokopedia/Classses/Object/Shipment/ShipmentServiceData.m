//
//  ShipmentServiceData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentServiceData.h"

@implementation ShipmentServiceData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"id" : @"productId",
        @"name" : @"name",
        @"description" : @"productDescription",
        @"active" : @"active",
    };
    [mapping addAttributeMappingsFromDictionary:mappings];
    return mapping;
}

@end
