//
//  NewOrderProduct.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModelView.h"

@interface OrderProduct : NSObject

@property NSInteger order_deliver_quantity;
@property (strong, nonatomic, nonnull) NSString *product_picture;
@property (strong, nonatomic, nonnull) NSString *product_price;
@property (strong, nonatomic, nonnull) NSString *order_detail_id;
@property (strong, nonatomic, nonnull) NSString *product_notes;
@property (strong, nonatomic, nonnull) NSString *product_status;
@property (strong, nonatomic, nonnull) NSString *order_subtotal_price;
@property (strong, nonatomic, nonnull) NSString *product_id;
@property NSInteger product_quantity;
@property (strong, nonatomic, nonnull) NSString *product_weight;
@property (strong, nonatomic, nonnull) NSString *order_subtotal_price_idr;
@property NSInteger product_reject_quantity;
@property (strong, nonatomic, nonnull) NSString *product_name;
@property (strong, nonatomic, nonnull) NSString *product_url;
@property (strong, nonatomic, nonnull) NSString *product_description;
@property (strong, nonatomic, nonnull) NSString *product_normal_price;
@property (strong, nonatomic, nonnull) NSString *product_current_weight;
@property (strong, nonatomic, nonnull) NSString *product_price_currency;
@property (strong, nonatomic, nonnull) NSString *product_weight_unit;


@property (strong, nonatomic, nonnull) ProductModelView *viewModel;

//not used for mapping
@property BOOL emptyStock;

+(RKObjectMapping*)mapping;

@end
