//
//  OrderShop.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderShop.h"

@implementation OrderShop

- (NSString *)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"shop_uri",
                      @"shop_id",
                      @"shop_name",
                      @"shop_pic"
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
