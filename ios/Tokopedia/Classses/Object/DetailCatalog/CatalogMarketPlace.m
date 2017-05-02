//
//  CatalogMarketPlace.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogMarketPlace.h"

@implementation CatalogMarketPlace

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"min_price",
                      @"time",
                      @"name",
                      @"max_price"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
