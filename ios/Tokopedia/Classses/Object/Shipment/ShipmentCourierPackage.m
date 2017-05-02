//
//  ShipmenCourierPackage.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentCourierPackage.h"

@implementation ShipmentCourierPackage

- (id)description {
    return _name;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"desc", @"active", @"name", @"sp_id"]];
    return mapping;
}

@end
