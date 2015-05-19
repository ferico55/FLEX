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

@interface OrderTransaction : NSObject

@property (strong, nonatomic) NSString *order_JOB_status;
@property (strong, nonatomic) OrderCustomer *order_customer;
@property (strong, nonatomic) OrderPayment *order_payment;
@property (strong, nonatomic) OrderDetail *order_detail;
@property (strong, nonatomic) NSString *order_auto_resi;
@property (strong, nonatomic) OrderDeadline *order_deadline;
@property (strong, nonatomic) NSString *order_auto_awb;
@property (strong, nonatomic) NSArray *order_products;
@property (strong, nonatomic) OrderShipment *order_shipment;
@property (strong, nonatomic) OrderLast *order_last;
@property (strong, nonatomic) NSMutableArray *order_history;
@property (strong, nonatomic) OrderDestination *order_destination;

@end
