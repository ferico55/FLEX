//
//  RateData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RateData.h"

@implementation RateData

+(NSDictionary *)attributeMappingDictionary
{
    return @{@"id":@"dataID",
             @"type":@"type"};
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attributes" toKeyPath:@"attributes" withMapping:[RateAttributes mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
