//
//  DetailCatalogResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailCatalogResult.h"

@implementation DetailCatalogResult

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"catalog_image",
                      @"catalog_description"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_info" toKeyPath:@"catalog_info" withMapping:[CatalogInfo mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_review" toKeyPath:@"catalog_review" withMapping:[CatalogReview mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_market_price" toKeyPath:@"catalog_market_price" withMapping:[CatalogMarketPlace mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_specs" toKeyPath:@"catalog_specs" withMapping:[CatalogSpecs mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_shops" toKeyPath:@"catalog_shops" withMapping:[CatalogShops mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_location" toKeyPath:@"catalog_location" withMapping:[CatalogLocation mapping]]];
    return mapping;
}

@end
