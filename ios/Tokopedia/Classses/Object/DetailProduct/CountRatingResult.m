//
//  CountRatingResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CountRatingResult.h"

@implementation CountRatingResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"count_score_good",
                      @"count_score_bad",
                      @"count_score_neutral"
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
