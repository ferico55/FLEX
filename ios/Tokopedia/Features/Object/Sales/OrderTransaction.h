//
//  NewOrderTransaction.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderCustomer.h"
#import "OrderPayment.h"
#import "OrderDetail.h"
#import "OrderDeadline.h"
#import "OrderProduct.h"
#import "OrderShipment.h"
#import "OrderLast.h"
#import "OrderHistory.h"
#import "OrderDestination.h"
#import "OrderSellerShop.h"
#import "Tkpd.h"
#import "DriverInfo.h"

@interface OrderTransaction : NSObject <TKPObjectMapping>

@property (strong, nonatomic, nonnull) NSString *order_JOB_status;
@property (strong, nonatomic, nonnull) OrderCustomer *order_customer;
@property (strong, nonatomic, nonnull) OrderPayment *order_payment;
@property (strong, nonatomic, nonnull) OrderDetail *order_detail;
@property (strong, nonatomic, nonnull) NSString *order_auto_resi;
@property (strong, nonatomic, nonnull) OrderDeadline *order_deadline;
@property (strong, nonatomic, nonnull) NSString *order_auto_awb;
@property (strong, nonatomic, nonnull) NSMutableArray *order_products;
@property (strong, nonatomic, nonnull) OrderShipment *order_shipment;
@property (strong, nonatomic, nonnull) OrderLast *order_last;
@property (strong, nonatomic, nonnull) NSMutableArray *order_history;
@property (strong, nonatomic, nonnull) OrderDestination *order_destination;
@property (strong, nonatomic, nonnull) OrderSellerShop *order_shop;
@property NSInteger order_is_pickup;
@property (strong, nonatomic, nullable) DriverInfo *driver_info;
@property NSInteger order_shipping_retry;

@property (strong, nonatomic, nonnull) NSString *deadline_string;
@property (strong, nonatomic, nonnull) NSString *deadline_label;
@property (nonatomic) BOOL deadline_hidden;
@end
