//
//  PromoShop.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoShop.h"

@implementation PromoShop

+(RKObjectMapping *)mapping{
    RKObjectMapping* promoShopMapping = [RKObjectMapping mappingForClass:[PromoShop class]];
    [promoShopMapping addAttributeMappingsFromDictionary:@{@"id":@"shop_id"}];
    [promoShopMapping addAttributeMappingsFromArray:@[@"name",
                                                      @"domain",
                                                      @"location",
                                                      @"gold_shop",
                                                      @"lucky_shop",
                                                      @"uri"
                                                      ]];
    [promoShopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image_shop"
                                                                                     toKeyPath:@"image_shop"
                                                                                   withMapping:[PromoShopImage mapping]]];
    
    return promoShopMapping;
}

- (NSString *)_name {
    return [_name kv_decodeHTMLCharacterEntities];
}

@end
