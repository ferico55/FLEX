//
//  CatalogReview.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogReview.h"

@implementation CatalogReview

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"review_from_image",
                      @"review_rating",
                      @"review_url",
                      @"review_from_url",
                      @"review_from",
                      @"catalog_id",
                      @"review_description"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
