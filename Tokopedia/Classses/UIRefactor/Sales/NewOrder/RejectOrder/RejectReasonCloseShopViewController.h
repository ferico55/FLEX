//
//  RejectReasonCloseShopViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@interface RejectReasonCloseShopViewController : UIViewController
@property (strong, nonatomic) OrderTransaction* order;
@end
