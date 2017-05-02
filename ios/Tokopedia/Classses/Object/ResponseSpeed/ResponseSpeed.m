//
//  ResponseSpeed.m
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResponseSpeed.h"

@implementation ResponseSpeed

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"one_day",
                      @"two_days",
                      @"three_days",
                      @"speed_level",
                      @"badge",
                      @"count_total"
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
