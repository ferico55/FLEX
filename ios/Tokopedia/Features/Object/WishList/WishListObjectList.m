//
//  WishListObjectList.m
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "WishListObjectList.h"
#import "ProductModelView.h"

@implementation WishListObjectList

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (BOOL)is_product_preorder {
    return _product_preorder == 1 ? YES : NO;
}

- (BOOL)is_product_wholesale {
    return _product_wholesale == 1 ? YES : NO;
}

- (ProductModelView*)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        [viewModel setIsProductBuyAble:[self.product_available isEqualToString:@"1"]];
        [viewModel setIsWholesale:self.is_product_wholesale];
        [viewModel setIsProductPreorder:self.is_product_preorder];
        [viewModel setShopLocation:self.shop_location];
        [viewModel setBadges:self.badges];
        
        _viewModel = viewModel;
    }
    return _viewModel;
}

- (NSDictionary *)productFieldObjects {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[_product_price componentsSeparatedByCharactersInSet:characterSet]
                              componentsJoinedByString: @""];
    NSDictionary *productFieldObjects = @{
        @"name"     : _product_name,
        @"id"       : _product_id,
        @"price"    : productPrice,
        @"brand"    : _shop_name,
    };
    return productFieldObjects;
}

@end
