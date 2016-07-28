//
//  FavoriteShopActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShopActionResult.h"

@implementation FavoriteShopActionResult

+ (NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"content",
                      @"is_success"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}
+ (RKObjectMapping *)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
}

@end
