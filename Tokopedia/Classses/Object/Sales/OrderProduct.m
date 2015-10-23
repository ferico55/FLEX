//
//  NewOrderProduct.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderProduct.h"

@implementation OrderProduct

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *tempViewModel = [ProductModelView new];
        tempViewModel.productName= _product_name;
        tempViewModel.productPriceIDR = _product_price;
        tempViewModel.productThumbUrl = _product_picture;
        tempViewModel.productQuantity = [NSString stringWithFormat:@"%zd",_product_quantity];
        tempViewModel.productTotalWeight = _product_weight;
        tempViewModel.productNotes = _product_notes;
        
        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

-(NSString *)product_notes
{
    return [_product_notes kv_decodeHTMLCharacterEntities];
}

@end
