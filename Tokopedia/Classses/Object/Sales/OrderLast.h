//
//  NewOrderLast.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderLast : NSObject <TKPObjectMapping>

@property NSInteger last_order_id;
@property (strong, nonatomic) NSString *last_shipment_id;
@property (strong, nonatomic) NSString *last_est_shipping_left;
@property (strong, nonatomic) NSString *last_order_status;
@property (strong, nonatomic) NSString *last_status_date;
@property NSInteger last_pod_code;
@property (strong, nonatomic) NSString *last_pod_desc;
@property (strong, nonatomic) NSString *last_shipping_ref_num;
@property NSInteger last_pod_receiver;
@property (strong, nonatomic) NSString *last_comments;
@property (strong, nonatomic) NSString *last_buyer_status;
@property (strong, nonatomic) NSString *last_status_date_wib;
@property (strong, nonatomic) NSString *last_seller_status;

@end
