//
//  TransactionCartList.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductDetail.h"
#import "ShippingInfoShipments.h"
#import "AddressFormList.h"
#import "ShopInfo.h"
#import "Errors.h"

#import "CartModelView.h"

@interface TransactionCartList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *cart_total_logistic_fee;
@property(nonatomic,strong) ShippingInfoShipments *cart_shipments;
@property(nonatomic,strong) NSArray<ProductDetail*> *cart_products;
@property (nonatomic,strong) AddressFormList *cart_destination;

@property (nonatomic, strong) NSString *cart_total_cart_count;
@property (nonatomic, strong) NSString *cart_total_logistic_fee_idr;
@property (nonatomic, strong) NSString *cart_can_process;
@property (nonatomic, strong) NSString *cart_total_product_price;
@property (nonatomic, strong) NSNumber *cart_insurance_price;
@property (nonatomic, strong) NSString *cart_total_product_price_idr;
@property (nonatomic, strong) NSString *cart_total_weight;
@property (nonatomic, strong) NSString *cart_customer_id;
@property (nonatomic, strong) NSNumber *cart_insurance_prod;
@property (nonatomic, strong) NSString *cart_insurance_name;
@property (nonatomic, strong) NSString *cart_total_amount_idr;
@property (nonatomic, strong) NSString *cart_shipping_rate_idr;
@property (nonatomic, strong) NSString *cart_is_allow_checkout;
@property (nonatomic, strong) NSString *cart_product_type;
@property (nonatomic, strong) NSNumber *cart_force_insurance;
@property (nonatomic, strong) NSNumber *cart_cannot_insurance;

@property (nonatomic, strong) NSString *cart_error_message_1;
@property (nonatomic, strong) NSString *cart_error_message_2;

@property (nonatomic, strong) NSString *cart_total_product;
@property (nonatomic, strong) NSString *cart_insurance_price_idr;
@property (nonatomic, strong) NSString *cart_total_amount;
@property (nonatomic, strong) NSString *cart_shipping_rate;
@property (nonatomic, strong) NSString *cart_logistic_fee;

@property (nonatomic, strong) NSString *cart_is_price_changed;
@property (nonatomic, strong) NSString *cart_is_dropshipper;
@property (nonatomic, strong) NSString *cart_dropship_name;
@property (nonatomic, strong) NSString *cart_dropship_phone;

@property (nonatomic, strong) NSString *cart_dropship_param;
@property (nonatomic, strong) NSString *cart_partial_param;

@property (nonatomic, strong) NSString *cart_is_partial;
@property (nonatomic, strong) NSArray<Errors *> *errors;

@property BOOL isDropshipperNameError;
@property BOOL isDropshipperPhoneError;

@property (nonatomic, strong) ShopInfo *cart_shop;

@property (nonatomic, strong) CartModelView *viewModel;

@end
