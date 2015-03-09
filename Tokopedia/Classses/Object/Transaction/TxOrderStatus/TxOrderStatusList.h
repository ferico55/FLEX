//
//  TxOrderStatusList.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
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
#import "OrderShop.h"
#import "OrderButton.h"

@interface TxOrderStatusList : NSObject

@property (strong, nonatomic) NSString *order_JOB_status;
@property (strong, nonatomic) OrderDetail *order_detail;
@property (strong, nonatomic) NSString *order_auto_resi;
@property (strong, nonatomic) OrderDeadline *order_deadline;
@property (strong, nonatomic) NSString *order_auto_awb;
@property (strong, nonatomic) OrderButton *order_button;
@property (strong, nonatomic) NSArray *order_products;
@property (strong, nonatomic) OrderShop *order_shop;
@property (strong, nonatomic) OrderShipment *order_shipment;
@property (strong, nonatomic) OrderLast *order_last;
@property (strong, nonatomic) NSArray *order_history;
@property (strong, nonatomic) NSString *order_JOB_detail;
@property (strong, nonatomic) OrderDestination *order_destination;

@end
