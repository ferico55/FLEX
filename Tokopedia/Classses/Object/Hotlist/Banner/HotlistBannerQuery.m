//
//  HotlistBannerQuery.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistBannerQuery.h"

@implementation HotlistBannerQuery
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"negative_keyword",
                      @"sc",
                      @"ob",
                      @"terms",
                      @"fshop",
                      @"q",
                      @"pmin",
                      @"pmax",
                      @"type",
                      @"shop_id",
                      @"hot_id"
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
