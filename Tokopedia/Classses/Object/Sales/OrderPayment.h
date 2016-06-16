//
//  NewOrderPayment.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderPayment : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *payment_process_due_date;
@property (strong, nonatomic) NSString *payment_komisi;
@property (strong, nonatomic) NSString *payment_verify_date;
@property (strong, nonatomic) NSString *payment_shipping_due_date;
@property NSInteger payment_process_day_left;
@property NSInteger payment_gateway_id;
@property (strong, nonatomic) NSString *payment_gateway_image;
@property NSInteger payment_shipping_day_left;
@property (strong, nonatomic) NSString *payment_gateway_name;

@end
