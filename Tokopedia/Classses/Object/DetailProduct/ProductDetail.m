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
    NSDictionary *productFieldObjects;
    @try {
        NSString *productPrice;
        if(_product_price) {
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
            productPrice = [[_product_price componentsSeparatedByCharactersInSet:characterSet]
                            componentsJoinedByString: @""];
        }
        productFieldObjects = @{
            @"id"       : _product_id?:@"",
            @"name"     : _product_name?:@"",
            @"pic"      : _product_pic?:@"",
            @"price"    : productPrice?:@"",
            @"price_format" : _product_price,
            @"quantity" : _product_quantity?:@"",
            @"url"      : _product_url?:@"",
        };
    }
    @catch (NSException *exception) {
        productFieldObjects = @{};
    }
    @finally {
        return productFieldObjects;
    }
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"product_weight_unit",
                      @"product_weight_unit_name",
                      @"product_weight",
                      @"product_description",
                      @"product_price",
                      @"price",
                      @"product_insurance",
                      @"product_condition",
                      @"product_min_order",
                      @"product_status",
                      @"product_last_update",
                      @"product_id",
                      @"product_price_alert",
                      @"product_name",
                      @"product_url",
                      @"product_uri",
                      @"product_already_wishlist",
                      @"product_price_fmt",
                      @"product_currency_id", //product_price_currency_value(cart)
                      @"product_currency",    //product_price_currency_value(cart)
                      @"product_etalase_id",
                      @"product_move_to",
                      @"product_etalase",
                      @"product_department_id",
                      @"product_short_desc",
                      @"product_department_tree",
                      @"product_must_insurance",
                      @"product_returnable",
                      @"product_quantity",
                      @"product_notes",
                      @"product_price_idr",
                      @"product_total_price",
                      @"product_total_price_idr",
                      @"product_pic",
                      @"product_use_insurance",
                      @"product_cart_id",
                      @"product_total_weight",
                      @"product_error_msg",
                      @"product_price_last"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}


@end
