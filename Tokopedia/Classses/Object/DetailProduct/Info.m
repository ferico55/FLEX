//
//  Info.m
//  Tokopedia
//
//  Created by IT Tkpd on 4/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "Info.h"

@implementation Info
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"product_returnable",
                      @"shop_has_terms",];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
