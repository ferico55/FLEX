//
//  TransactionCartList.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartList.h"

@implementation TransactionCartList

- (CartModelView *)viewModel {
    if(_viewModel == nil) {
        CartModelView *tempViewModel = [CartModelView new];
        tempViewModel.cartIsPriceChanged = _cart_is_price_changed;
        tempViewModel.cartShopName = _cart_shop.shop_name;
        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}

@end
