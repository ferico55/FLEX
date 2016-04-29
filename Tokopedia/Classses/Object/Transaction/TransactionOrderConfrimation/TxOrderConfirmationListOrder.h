//
//  TxOrderConfirmationListOrder.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OrderProduct.h"
#import "OrderShop.h"
#import "OrderShipment.h"
#import "OrderDestination.h"
#import "OrderDetail.h"

@interface TxOrderConfirmationListOrder : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *order_JOB_status;
@property (nonatomic, strong) NSArray *order_products;
@property (nonatomic, strong) OrderShop *order_shop;
@property (nonatomic, strong) OrderShipment *order_shipment;
@property (nonatomic, strong) OrderDestination *order_destination;
@property (nonatomic, strong) OrderDetail *order_detail;
@property (nonatomic, strong) NSArray *order_auto_resi;

@end
