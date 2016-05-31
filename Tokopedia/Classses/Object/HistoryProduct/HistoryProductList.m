//
//  HistoryProductList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HistoryProductList.h"
#import "ProductModelView.h"

@implementation HistoryProductList

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        [viewModel setLuckyMerchantImageURL:self.shop_lucky];
        [viewModel setIsProductPreorder:self.product_preorder];
        [viewModel setShopLocation:self.shop_location];
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

@end
