//
//  SearchItem.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "List.h"

@implementation List

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        
        NSString *statsProduct = [NSString stringWithFormat:@"%@ Ulasan   %@ Diskusi",
                                  self.product_review_count,
                                  self.product_talk_count];
        NSString *statsCatalog = [NSString stringWithFormat:@"%@ Toko",
                                  self.catalog_count_shop];
        [viewModel setStatusInfo:(self.product_name)?statsProduct:statsCatalog];
        [viewModel setProductName:self.product_name?:self.catalog_name];
        [viewModel setProductPrice:self.product_price?:self.catalog_price];
        [viewModel setProductShop:self.shop_name?:statsCatalog];
        [viewModel setProductThumbUrl:self.product_image?:self.catalog_image_300];
        [viewModel setProduct_review_count:self.product_review_count?:self.catalog_count_shop];
        [viewModel setProduct_talk_count:self.product_talk_count];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        [viewModel setProduct_image:self.product_image?:self.catalog_image_300];
        [viewModel setProduct_image_full:self.product_image_full?:self.catalog_image];

        
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

@end
