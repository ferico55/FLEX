//
//  PromoProduct.m
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoProduct.h"

@implementation PromoProduct

+(RKObjectMapping *)mapping{
    return nil;
}

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image_200];
        [viewModel setProductReview:self.product_review_count];
        [viewModel setProductTalk:self.product_talk_count];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        [viewModel setLuckyMerchantImageURL:self.shop_lucky];
        _viewModel = viewModel;
    }
    return _viewModel;
}

- (NSDictionary *)productFieldObjects {
    return @{
             @"id"   : _product_id?:@"",
             @"name" : _product_name?:@"",
             @"url"  : _product_url?:@"",
             @"price" : _product_price?:@""
    };
}

@end
