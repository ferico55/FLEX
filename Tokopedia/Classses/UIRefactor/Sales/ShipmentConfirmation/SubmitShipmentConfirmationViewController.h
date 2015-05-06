//
//  SubmitShipmentConfirmationViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipmentCourier.h"
#import "ShipmentCourierPackage.h"
#import "OrderTransaction.h"

@protocol SubmitShipmentConfirmationDelegate <NSObject>

@optional;
- (void)submitConfirmationReceiptNumber:(NSString *)receiptNumber courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage;

@end

@interface SubmitShipmentConfirmationViewController : UIViewController

@property (weak, nonatomic) id<SubmitShipmentConfirmationDelegate> delegate;
@property (strong, nonatomic) NSArray *shipmentCouriers;

@end
