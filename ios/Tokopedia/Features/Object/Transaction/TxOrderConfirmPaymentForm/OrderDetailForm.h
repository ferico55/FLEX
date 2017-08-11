//
//  Order.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDetailForm : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *order_left_amount_idr;
@property (nonatomic, strong) NSString *order_deposit_used_idr;
@property (nonatomic, strong) NSString *order_invoice;
@property (nonatomic, strong) NSString *order_confirmation_code_idr;
@property (nonatomic, strong) NSString *order_grand_total_idr;
@property (nonatomic, strong) NSString *order_left_amount;
@property (nonatomic, strong) NSString *order_confirmation_code;
@property (nonatomic, strong) NSString *order_deposit_used;
@property (nonatomic, strong) NSString *order_depositable;
@property (nonatomic, strong) NSString *order_grand_total;

@property (nonatomic, strong) NSString *order_payment_amount;
@property (nonatomic, strong) NSString *order_payment_month;
@property (nonatomic, strong) NSString *order_payment_day;
@property (nonatomic, strong) NSString *order_payment_year;

@end
