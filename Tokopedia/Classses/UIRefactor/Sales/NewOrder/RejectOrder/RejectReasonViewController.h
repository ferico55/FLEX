//
//  RejectReasonViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RejectReason.h"
#import "OrderTransaction.h"

@interface RejectReasonViewController : UIViewController
@property (strong, nonatomic) OrderTransaction* order;
@end
