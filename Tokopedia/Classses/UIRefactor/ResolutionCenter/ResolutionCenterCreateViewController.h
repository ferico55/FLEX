//
//  ResolutionCenterCreateViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TxOrderStatusList.h"

@interface ResolutionCenterCreateViewController : UIViewController
@property (strong, nonatomic) TxOrderStatusList* order;
@property BOOL product_is_received;
@end
