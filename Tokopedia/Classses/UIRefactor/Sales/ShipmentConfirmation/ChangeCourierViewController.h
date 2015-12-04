//
//  ChangeCourierViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/3/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipmentCourier.h"
#import "ShipmentCourierPackage.h"
#import "OrderTransaction.h"

@protocol ChangeCourierDelegate <NSObject>

@optional;
- (void)submitConfirmationReceiptNumber:(NSString *)receiptNumber courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage;
- (void)successConfirmOrder:(OrderTransaction *)order;

@end

@interface ChangeCourierViewController : UIViewController

@property (weak, nonatomic) id<ChangeCourierDelegate> delegate;
@property (strong, nonatomic) NSArray *shipmentCouriers;
@property (strong, nonatomic) OrderTransaction *order;

@end