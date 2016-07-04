//
//  RejectReasonWrongPriceViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@interface RejectReasonWrongPriceViewController : UIViewController
@property (strong, nonatomic) OrderTransaction* order;
@property (strong, nonatomic) NSString* reasonCode;
@end
