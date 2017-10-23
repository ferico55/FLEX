//
//  ImageSearchProduct.m
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImageSearchProduct.h"

@implementation ImageSearchProduct

- (ProductModelView *)viewModel {
    if(!_viewModel) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image];
        [viewModel setProductReview:self.product_review_count];
        [viewModel setProductTalk:self.product_talk_count];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]?YES:NO];
        _viewModel = viewModel;
    }    
    return _viewModel;
}

@end
