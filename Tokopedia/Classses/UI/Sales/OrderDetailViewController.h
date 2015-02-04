//
//  NewOrderDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@protocol OrderDetailDelegate <NSObject>

@optional;
- (void)didReceiveActionType:(NSString *)actionType reason:(NSString *)reason products:(NSArray *)products productQuantity:(NSArray *)productQuantity;

@end

@interface OrderDetailViewController : UIViewController

@property (strong, nonatomic) OrderTransaction *transaction;
@property (weak, nonatomic) id<OrderDetailDelegate> delegate;

@end
