//
//  ResolutionCenterCreateStepTwoViewController.h
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

#import "ResolutionCenterCreateViewController.h"

@interface ResolutionCenterCreateStepTwoViewController : UIViewController
@property (strong, nonatomic) ResolutionCenterCreateResult* result;
@property (strong, nonatomic) TxOrderStatusList* order;
@property BOOL shouldFlushOptions;

-(BOOL)verifyForm;
@property TypeReso *type;

@end
