//
//  TransactionSummaryDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionCartList.h"
#import "TransactionSummaryBCAParam.h"

@interface TransactionSummaryDetail : NSObject

@property (nonatomic,strong) NSArray *carts;

@property (nonatomic,strong) NSString *voucher_amount_idr;
@property (nonatomic,strong) NSString *deposit_after;
@property (nonatomic,strong) NSString *grand_total;
@property (nonatomic,strong) NSString *payment_left_idr;
@property (nonatomic,strong) NSString *confirmation_id;
@property (nonatomic,strong) NSString *step;
@property (nonatomic,strong) NSString *deposit_left;
@property (nonatomic,strong) NSString *data_partial;
@property (nonatomic,strong) NSString *use_deposit;
@property (nonatomic,strong) NSString *payment_id;
@property (nonatomic,strong) NSString *bca_param;
@property (nonatomic,strong) NSString *use_otp;
@property (nonatomic,strong) NSString *now_time;
@property (nonatomic,strong) NSString *emoney_code;
@property (nonatomic,strong) NSString *unik;
@property (nonatomic,strong) NSString *grand_total_idr;
@property (nonatomic,strong) NSString *deposit_amount_idr;
@property (nonatomic,strong) NSString *ga_data;
@property (nonatomic,strong) NSString *discount_gateway_idr;
@property (nonatomic,strong) NSString *user_deposit_idr;
@property (nonatomic,strong) NSString *msisdn_verified;
@property (nonatomic,strong) NSNumber *gateway;
@property (nonatomic,strong) NSString *conf_code;
@property (nonatomic,strong) NSString *dropship_list;
@property (nonatomic,strong) NSString *conf_due_date;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *processing;
@property (nonatomic,strong) NSString *grand_total_before_fee_idr;
@property (nonatomic,strong) NSString *discount_gateway;
@property (nonatomic,strong) NSString *gateway_name;
@property (nonatomic,strong) NSString *status_unik;
@property (nonatomic,strong) NSString *user_deposit;
@property (nonatomic,strong) NSString *lock_mandiri;
@property (nonatomic,strong) NSString *deposit_amount;
@property (nonatomic,strong) NSString *voucher_amount;
@property (nonatomic,strong) NSString *grand_total_before_fee;
@property (nonatomic,strong) NSString *conf_code_idr;
@property (nonatomic,strong) NSString *payment_left;

@end
