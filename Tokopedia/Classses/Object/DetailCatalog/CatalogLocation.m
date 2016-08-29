//
//  CatalogLocation.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogLocation.h"

@implementation CatalogLocation

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"location_name",
                      @"location_id",
                      @"total_shop"
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
