//
//  CatalogResult.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogResult.h"

@implementation CatalogResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[CatalogList mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
