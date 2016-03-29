//
//  OrderConfirmationDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderConfirmationDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *left_amount;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *pay_due_date;
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *open_amount_before_fee;
@property (nonatomic, strong) NSString *confirmation_id;
@property (nonatomic, strong) NSString *deposit_amount;
@property (nonatomic, strong) NSString *open_amount;
@property (nonatomic, strong) NSString *deposit_amount_plain;
@property (nonatomic, strong) NSString *voucher_amount;
@property (nonatomic, strong) NSString *customer_id;
@property (nonatomic, strong) NSString *payment_type;
@property (nonatomic, strong) NSString *total_item;
@property (nonatomic, strong) NSString *shop_list;

@end
