//
//  CatalogSpecs.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogSpecs.h"

@implementation CatalogSpecs

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"spec_header"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"spec_childs" toKeyPath:@"spec_childs" withMapping:[SpecChilds mapping]]];
    return mapping;
}

@end
