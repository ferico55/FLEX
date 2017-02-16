//
//  NewOrderDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"
#import "ShipmentCourier.h"
#import "ShipmentCourierPackage.h"
#import "OrderBooking.h"
#import "Tokopedia-Swift.h"

@protocol OrderDetailDelegate <NSObject>

@optional;
- (void)didReceiveActionType:(ProceedType)actionType
                      reason:(NSString *)reason
                    products:(NSArray *)products
             productQuantity:(NSArray *)productQuantity;

- (void)didReceiveActionType:(ProceedType)type
                     courier:(ShipmentCourier *)courier
              courierPackage:(ShipmentCourierPackage *)courierPackage
               receiptNumber:(NSString *)receiptNumber
             rejectionReason:(NSString *)rejectionReason;
- (void)successConfirmOrder:(OrderTransaction *)order;
- (void)refreshData;

@end

@interface OrderDetailViewController : UIViewController

@property (strong, nonatomic) OrderTransaction *transaction;
@property (weak, nonatomic) id<OrderDetailDelegate> delegate;
@property (strong, nonatomic) NSArray *shipmentCouriers;
@property (strong, nonatomic) OrderBooking *booking;
@property BOOL shouldRequestIDropCode;

@property BOOL isDetailNewOrder;
@property BOOL isDetailShipmentConfirmation;

@property (copy, nonatomic) void(^didAcceptOrder)();
@property (copy) void(^onSuccessRetry)(BOOL isSuccess);

@end
