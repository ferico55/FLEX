//
//  NewOrderDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@interface OrderDetailViewController : UIViewController

@property (strong, nonatomic) OrderTransaction *transaction;

@end
