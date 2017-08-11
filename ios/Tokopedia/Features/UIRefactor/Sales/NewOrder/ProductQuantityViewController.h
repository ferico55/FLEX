//
//  ProductQuantityViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductQuantityViewController : UIViewController

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSString *orderID;
@property (strong, nonatomic) NSString *shippingLeft;

@property (copy, nonatomic) void(^didAcceptOrder)();

@end
