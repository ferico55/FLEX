//
//  CatalogInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogInfo.h"

@implementation CatalogInfo

- (NSString *)catalog_name {
    return [_catalog_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)catalog_description {
    return [NSString convertHTML:[_catalog_description kv_decodeHTMLCharacterEntities]];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"catalog_description",
                      @"catalog_key",
                      @"catalog_department_id",
                      @"catalog_id",
                      @"catalog_name",
                      @"catalog_url"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_price" toKeyPath:@"catalog_price" withMapping:[CatalogPrice mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_images" toKeyPath:@"catalog_images" withMapping:[CatalogImages mapping]]];
    return mapping;
}

@end
