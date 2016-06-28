//
//  NewOrderProduct.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderProduct.h"

@implementation OrderProduct
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_deliver_quantity",
                      @"product_picture",
                      @"product_price",
                      @"order_detail_id",
                      @"product_notes",
                      @"product_status",
                      @"order_subtotal_price",
                      @"product_id",
                      @"product_quantity",
                      @"product_weight",
                      @"order_subtotal_price_idr",
                      @"product_reject_quantity",
                      @"product_name",
                      @"product_url",
                      @"product_description",
                      @"product_normal_price",
                      @"product_current_weight",
                      @"product_price_currency",
                      @"product_weight_unit"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *tempViewModel = [ProductModelView new];
        tempViewModel.productName = [_product_name kv_decodeHTMLCharacterEntities];
        tempViewModel.productPriceIDR = _product_price;
        tempViewModel.productThumbUrl = _product_picture;
        tempViewModel.productQuantity = [NSString stringWithFormat:@"%zd",_product_quantity];
        tempViewModel.productTotalWeight = _product_weight;
        tempViewModel.productNotes = [_product_notes kv_decodeHTMLCharacterEntities];
        tempViewModel.isProductBuyAble = !_emptyStock;
        
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
