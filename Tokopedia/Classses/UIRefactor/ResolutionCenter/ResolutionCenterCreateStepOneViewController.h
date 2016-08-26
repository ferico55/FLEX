//
//  ResolutionCenterCreateStepOneViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResolutionCenterCreateData.h"
#import "ResolutionProductList.h"
#import "ResolutionCenterCreateResult.h"
#import "TxOrderStatusList.h"

@interface ResolutionCenterCreateStepOneViewController : UIViewController

@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@property (strong, nonatomic) ResolutionCenterCreateResult* result;
@property (strong, nonatomic) TxOrderStatusList* order;
@property BOOL product_is_received;
@end
