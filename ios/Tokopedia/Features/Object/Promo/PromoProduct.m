//
//  PromoProduct.m
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoProduct.h"
#import "Tokopedia-Swift.h"

@implementation PromoProduct

+(RKObjectMapping *)mapping{
    RKObjectMapping *promoProductMapping = [RKObjectMapping mappingForClass:[PromoProduct class]];
    [promoProductMapping addAttributeMappingsFromDictionary:@{@"id":@"product_id"}];
    [promoProductMapping addAttributeMappingsFromArray:@[@"name",
                                                         @"uri",
                                                         @"relative_uri",
                                                         @"price_format",
                                                         @"count_talk_format",
                                                         @"count_review_format",
                                                         @"product_preorder",
                                                         @"product_rating"
                                                         ]];
    [promoProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"category"
                                                                                        toKeyPath:@"category"
                                                                                      withMapping:[PromoCategory mapping]]];
    [promoProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wholesale_price"
                                                                                        toKeyPath:@"wholesale_price"
                                                                                      withMapping:[WholesalePrice mappingForPromo]]];
    [promoProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image"
                                                                                        toKeyPath:@"image"
                                                                                      withMapping:[PromoProductImage mapping]]];
    
    [promoProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"labels" toKeyPath:@"labels" withMapping:[ProductLabel mapping]]];
    
    return promoProductMapping;
}

- (NSString *)name {
    return [_name kv_decodeHTMLCharacterEntities];
}


- (NSDictionary *)productFieldObjects {
    return @{
             @"id"   : _product_id?:@"",
             @"name" : _name?:@"",
             @"url"  : _relative_uri?:@"",
             @"price" : _price_format?:@""
    };
}

@end
