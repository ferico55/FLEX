//
//  ListFavorite.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ListFavoriteShop.h"

@implementation ListFavoriteShop

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                        @"shop_total_etalase",
                        @"shop_image",
                        @"shop_location",
                        @"shop_id",
                        @"shop_total_sold",
                        @"shop_total_product",
                        @"shop_name"
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
