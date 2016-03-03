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

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"cart_total_logistic_fee",
                      @"cart_total_cart_count",
                      @"cart_total_logistic_fee_idr",
                      @"cart_can_process",
                      @"cart_total_product_price",
                      @"cart_insurance_price",
                      @"cart_total_product_price_idr",
                      @"cart_total_weight",
                      @"cart_customer_id",
                      @"cart_insurance_prod",
                      @"cart_insurance_name",
                      @"cart_total_amount_idr",
                      @"cart_shipping_rate_idr",
                      @"cart_is_allow_checkout",
                      @"cart_product_type",
                      @"cart_force_insurance",
                      @"cart_cannot_insurance",
                      @"cart_error_message_1",
                      @"cart_error_message_2",
                      @"cart_total_product",
                      @"cart_insurance_price_idr",
                      @"cart_total_amount",
                      @"cart_shipping_rate",
                      @"cart_logistic_fee",
                      @"cart_is_price_changed"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_shipments" toKeyPath:@"cart_shipments" withMapping:[ShippingInfoShipments mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_destination" toKeyPath:@"cart_destination" withMapping:[AddressFormList mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_shop" toKeyPath:@"cart_shop" withMapping:[ShopInfo mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_products" toKeyPath:@"cart_products" withMapping:[ProductDetail mapping]];
    [mapping addPropertyMapping:relMapping];
    
    return mapping;
}


@end
