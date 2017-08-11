//
//  SearchItem.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "List.h"

@implementation List

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)catalog_name {
    return [_catalog_name kv_decodeHTMLCharacterEntities];
}

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image];
        [viewModel setProductReview:self.product_review_count];
        [viewModel setProductTalk:self.product_talk_count];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        _viewModel = viewModel;
    }
    return _viewModel;
}

- (CatalogModelView *)catalogViewModel {
    if(_catalogViewModel == nil) {
        CatalogModelView *viewModel = [[CatalogModelView alloc] init];
        [viewModel setCatalogName:self.catalog_name];
        [viewModel setCatalogPrice:self.catalog_price];
        [viewModel setCatalogSeller:self.catalog_count_shop];
        [viewModel setCatalogThumbUrl:self.catalog_image_300];
        _catalogViewModel = viewModel;
    }
    return _catalogViewModel;
}

- (NSDictionary *)productFieldObjects {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[_product_price componentsSeparatedByCharactersInSet:characterSet]
                              componentsJoinedByString: @""];
    NSDictionary *productFieldObjects = @{
        @"name"     : _product_name?:@"",
        @"id"       : _product_id?:@"",
        @"price"    : productPrice,
        @"brand"    : _shop_name?:@"",
    };
    return productFieldObjects;
}

@end
