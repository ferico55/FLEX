//
//  MyShopPaymentViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyShopShipmentTableViewController;
@interface MyShopPaymentViewController : UIViewController

@property (nonatomic, strong)NSDictionary *data;
@property (nonatomic, unsafe_unretained) MyShopShipmentTableViewController *myShopShipmentTableViewController;
@property (nonatomic, unsafe_unretained) NSArray *arrDataPayment;
@end
