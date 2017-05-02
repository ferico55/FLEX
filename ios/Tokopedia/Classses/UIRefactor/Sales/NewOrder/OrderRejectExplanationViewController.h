//
//  OrderRejectExplanationViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@interface OrderRejectExplanationViewController : UIViewController
@property (strong, nonatomic) NSString* reasonCode;
@property (strong, nonatomic) OrderTransaction* order;

@end
