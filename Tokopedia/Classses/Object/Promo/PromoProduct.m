//
//  PromoProduct.m
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoProduct.h"
#import "ProductBadge.h"

@implementation PromoProduct

+(RKObjectMapping *)mapping{
    RKObjectMapping *promoProductMapping = [RKObjectMapping mappingForClass:[PromoProduct class]];
    [promoProductMapping addAttributeMappingsFromDictionary:@{@"id":@"product_id"}];
    [promoProductMapping addAttributeMappingsFromArray:@[@"name",
                                                         @"uri",
                                                         @"relative_uri",
                                                         @"price_format",
                                                         @"count_talk_format",
                                                         @"count_review_format"
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
    [promoProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"badges"
                                                                                        toKeyPath:@"badges"
                                                                                      withMapping:[ProductBadge mapping]]];
    
    return promoProductMapping;
}

- (NSString *)name {
    return [_name kv_decodeHTMLCharacterEntities];
}

- (ProductModelView *)viewModel {
    
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:_name];
        [viewModel setProductPrice:_price_format];
        viewModel.badges = _badges;
        /*
        [viewModel setProductShop:_];
        [viewModel setProductThumbUrl:self.product_image_200];
        [viewModel setProductReview:self.product_review_count];
        [viewModel setProductTalk:self.product_talk_count];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        [viewModel setLuckyMerchantImageURL:self.shop_lucky];
         */
        _viewModel = viewModel;
    }
    
    return _viewModel;
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
