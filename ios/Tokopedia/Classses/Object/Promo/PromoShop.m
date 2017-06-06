//
//  PromoShop.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoShop.h"
#import "Tokopedia-Swift.h"

@implementation PromoShop

+(RKObjectMapping *)mapping{
    RKObjectMapping* promoShopMapping = [RKObjectMapping mappingForClass:[PromoShop class]];
    [promoShopMapping addAttributeMappingsFromDictionary:@{@"id":@"shop_id",
                                                           @"image_product.image_url":@"productPhotoUrls"}];
    [promoShopMapping addAttributeMappingsFromArray:@[@"name",
                                                      @"domain",
                                                      @"location",
                                                      @"gold_shop",
                                                      @"enable_fav",
                                                      @"lucky_shop",
                                                      @"uri"
                                                      ]];
    [promoShopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image_shop"
                                                                                     toKeyPath:@"image_shop"
                                                                                   withMapping:[PromoShopImage mapping]]];
    [promoShopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"badges"
                                                                                        toKeyPath:@"badges"
                                                                                      withMapping:[ProductBadge mapping]]];
    return promoShopMapping;
}

- (NSString *)_name {
    return [_name kv_decodeHTMLCharacterEntities];
}

@end
