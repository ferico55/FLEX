//
//  CatalogPrice.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogPrice.h"

@implementation CatalogPrice

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"price_min",
                      @"price_max",
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
