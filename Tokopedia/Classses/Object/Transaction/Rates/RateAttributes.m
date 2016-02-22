//
//  RateAttributes.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RateAttributes.h"

@implementation RateAttributes

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"shipper_id",
                      @"shipper_name",
                      @"origin_id",
                      @"origin_name",
                      @"destination_id",
                      @"destination_name"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"products" toKeyPath:@"products" withMapping:[RateProduct mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}


@end
