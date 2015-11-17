//
//  ProductDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductDetail.h"

@implementation ProductDetail

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *tempViewModel = [ProductModelView new];
        tempViewModel.productName= _product_name;
        tempViewModel.productPriceIDR = _product_price_idr;
        tempViewModel.productThumbUrl = _product_pic;
        tempViewModel.productPriceBeforeChange = _product_price_last;
        tempViewModel.productQuantity = _product_quantity;
        tempViewModel.productTotalWeight = _product_total_weight;
        tempViewModel.productNotes = _product_notes;
        tempViewModel.productErrorMessage = _product_error_msg;
        
        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}

- (NSString *)product_description {
    return [_product_description kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)product_short_desc {
    return  [_product_short_desc kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_etalase {
    return [_product_etalase kv_decodeHTMLCharacterEntities];
}

- (NSDictionary *)productFieldObjects {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[_product_price componentsSeparatedByCharactersInSet:characterSet]
                              componentsJoinedByString: @""];
    NSDictionary *productFieldObjects = @{
        @"name"     : _product_name,
        @"id"       : _product_id,
        @"price"    : productPrice,
        @"quantity" : _product_quantity?:@""
    };
    return productFieldObjects;
}

@end
