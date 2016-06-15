//
//  RejectReasonEmptyStockViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderProduct.h"

@interface RejectReasonEmptyStockViewController : UIViewController
@property (strong, nonatomic) NSArray<OrderProduct*>* order_products;
@end
