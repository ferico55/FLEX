//
//  TransactionCartList.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartList.h"
#import "Tokopedia-Swift.h"

@implementation TransactionCartList

-(NSString *)cart_shipping_rate {
    return _cart_shipping_rate ?: @"0";
}

-(NSString *)cart_shipping_rate_idr {
    return _cart_shipping_rate_idr ?: @"Rp 0";
}

-(NSString *)cart_total_amount {
    return _cart_total_amount ?: @"0";
}

-(NSString *)cart_total_amount_idr {
    return _cart_total_amount_idr ?: @"Rp 0";
}

-(NSString *)cart_insurance_price {
    return _cart_insurance_price ?: @"0";
}

-(NSString *)cart_insurance_price_idr {
    return _cart_insurance_price_idr ?: @"Rp 0";
}

-(NSString *)insuranceUsedType {
    return _insuranceUsedType ?: @"1";
}

-(NSString *)insuranceUsedDefault {
    NSString *productPrice = [_cart_total_product_price integerValue]>=1000000 ? @"2" : @"1";
    return _insuranceUsedDefault ?: productPrice;
}

-(BOOL)isEditingEnabled {
    return ![[self.cart_products firstObject].product_hide_edit isEqualToString:@"1"];
}

- (CartModelView *)viewModel {
    if(_viewModel == nil) {
        CartModelView *tempViewModel = [CartModelView new];
        tempViewModel.cartIsPriceChanged = _cart_is_price_changed;
        tempViewModel.cartShopName = _cart_shop.shop_name;
        tempViewModel.isLuckyMerchant = _cart_shop.lucky_merchant;
        tempViewModel.logiscticFee = _cart_logistic_fee;
        tempViewModel.totalProductPriceIDR = _cart_total_product_price_idr;
        tempViewModel.insuranceFee = _cart_insurance_price;
        tempViewModel.shippingRateIDR = _cart_shipping_rate_idr;
        tempViewModel.totalAmountIDR = _cart_total_amount_idr;
        tempViewModel.errors = _errors;
        tempViewModel.isEditingEnabled = self.isEditingEnabled;
        
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
    [mapping addAttributeMappingsFromDictionary:@{@"cart_cat_id": @"categoryID",
                                                  @"cart_string": @"cartString",
                                                  @"cart_rates_string": @"rateString",
                                                  @"cart_rates_value": @"rateValue",
                                                  @"insurance_used_type": @"insuranceUsedType",
                                                  @"insurance_used_default": @"insuranceUsedDefault",
                                                  @"insurance_used_info": @"insuranceUsedInfo",
                                                  @"insurance_type": @"insuranceType",
                                                  @"insurance_type_info": @"insuranceTypeInfo",
                                                  @"insurance_price": @"insurancePrice"}];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_shipments" toKeyPath:@"cart_shipments" withMapping:[ShippingInfoShipments mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_destination" toKeyPath:@"cart_destination" withMapping:[AddressFormList mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_shop" toKeyPath:@"cart_shop" withMapping:[ShopInfo mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"errors" toKeyPath:@"errors" withMapping:[Errors mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"cart_products" toKeyPath:@"cart_products" withMapping:[ProductDetail mapping]];
    [mapping addPropertyMapping:relMapping];
    
    return mapping;
}


@end
