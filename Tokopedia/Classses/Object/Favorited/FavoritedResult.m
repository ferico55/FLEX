//
//  FavoritedResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedResult.h"

@implementation FavoritedResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"page",
                      @"total_page"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[ListFavorited mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
