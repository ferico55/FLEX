//
//  NewOrderDetail.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OrderRequestCancel.h"

@interface OrderDetail : NSObject

@property (strong, nonatomic) NSString *detail_insurance_price;
@property (strong, nonatomic) NSString *detail_open_amount;
@property NSInteger detail_total_add_fee;
@property NSInteger detail_partial_order;
@property NSInteger detail_quantity;
@property (strong, nonatomic) NSString *detail_product_price_idr;
@property (strong, nonatomic) NSString *detail_invoice;
@property (strong, nonatomic) NSString *detail_shipping_price_idr;
@property (strong, nonatomic) NSString *detail_pdf_path;
@property (strong, nonatomic) NSString *detail_additional_fee_idr;
@property (strong, nonatomic) NSString *detail_product_price;
@property NSInteger detail_force_insurance;
@property (strong, nonatomic) NSString *detail_open_amount_idr;
@property (strong, nonatomic) NSString *detail_additional_fee;
@property (strong, nonatomic) NSString *detail_order_id;
@property (strong, nonatomic) NSString *detail_total_add_fee_idr;
@property (strong, nonatomic) NSString *detail_order_date;
@property (strong, nonatomic) NSString *detail_shipping_price;
@property (strong, nonatomic) NSString *detail_pay_due_date;
@property CGFloat detail_total_weight;
@property (strong, nonatomic) NSString *detail_insurance_price_idr;
@property (strong, nonatomic) NSString *detail_pdf_uri;
@property (strong, nonatomic) NSString *detail_ship_ref_num;
@property NSInteger detail_force_cancel;
@property (strong, nonatomic) NSString *detail_print_address_uri;
@property (strong, nonatomic) NSString *detail_pdf;
@property NSInteger detail_order_status;

@property (strong, nonatomic) NSString *detail_dropship_name;
@property (strong, nonatomic) NSString *detail_dropship_telp;
@property NSInteger detail_free_return;
@property (strong, nonatomic) NSString *detail_free_return_msg;
@property (strong, nonatomic) OrderRequestCancel *detail_cancel_request;
@property (strong, nonatomic) NSString *invoiceURLString;

@property (strong, nonatomic) NSString *partialString;
@property (strong, nonatomic) NSString *additionalFeeTitle;
@property (strong, nonatomic) NSString *additionalFee;

@property (strong, nonatomic) NSString *detail_complaint_popup_title;
@property (strong, nonatomic) NSString *detail_complaint_popup_msg;
@property (strong, nonatomic) NSString *detail_finish_popup_title;
@property (strong, nonatomic) NSString *detail_finish_popup_msg;
@property (strong, nonatomic) NSString *detail_complaint_not_received_title;
@property (strong, nonatomic) NSString *detail_complaint_not_received_msg;

+(RKObjectMapping*)mapping;

@end
