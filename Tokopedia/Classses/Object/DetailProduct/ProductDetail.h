//
//  ProductDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

@class ProductReturnInfo;
#import <Foundation/Foundation.h>
#import "ProductModelView.h"
#import "Errors.h"


#define CProductID @"product_id"
#define CProductPrice @"product_price"
#define CProductCondition @"product_condition"
#define CProductName @"product_name"
#define CProductUri @"product_uri"
#define CProductPriceFmt @"product_price_fmt"

@interface ProductDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *product_weight_unit;
@property (nonatomic, strong) NSString *product_weight_unit_name;
@property (nonatomic, strong) NSString *product_weight;
@property (nonatomic, strong) NSString *product_description;
@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *product_insurance;
@property (nonatomic, strong) NSString *product_condition;
@property (nonatomic, strong) NSString *product_min_order;
@property (nonatomic, strong) NSString *product_status;
@property (nonatomic, strong) NSString *product_last_update;
@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) NSString *product_price_alert;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *product_url;
@property (nonatomic, strong) NSString *product_uri;
@property (nonatomic, strong) NSString *product_already_wishlist;
@property (nonatomic, strong) NSString *product_price_fmt;

@property (nonatomic, strong) NSString *product_currency_id; //product_price_currency_value(cart)
@property (nonatomic, strong) NSString *product_currency;    //product_price_currency_value(cart)
@property (nonatomic, strong) NSNumber *product_etalase_id;
@property (nonatomic, strong) NSString *product_move_to;
@property (nonatomic, strong) NSString *product_etalase;
@property (nonatomic) NSInteger product_department_id;
@property (nonatomic) NSString *product_short_desc;
@property (nonatomic) NSInteger product_department_tree;
@property (nonatomic, strong) NSString *product_must_insurance;
@property (nonatomic, strong) NSString *product_returnable;

@property (nonatomic, strong) NSString *product_quantity;
@property (nonatomic, strong) NSString *product_notes;
@property (nonatomic, strong) NSString *product_price_idr;
@property (nonatomic, strong) NSString *product_total_price;
@property (nonatomic, strong) NSString *product_total_price_idr;
@property (nonatomic, strong) NSString *product_pic;
@property (nonatomic, strong) NSString *product_picture;
@property (nonatomic, strong) NSString *product_use_insurance;
@property (nonatomic, strong) NSString *product_cart_id;
@property (nonatomic, strong) NSString *product_total_weight;
@property (nonatomic, strong) NSString *product_error_msg;
@property (nonatomic, strong) NSString *product_price_last;
@property (nonatomic, strong) NSString *product_cat_name;
@property (nonatomic, strong) ProductReturnInfo *return_info;

@property (nonatomic, strong) NSArray<Errors *> *errors;

@property (nonatomic, strong) ProductModelView *viewModel;

@property (nonatomic, strong) NSDictionary *productFieldObjects;

+ (NSInteger)maximumPurchaseQuantity;

@end
