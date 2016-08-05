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

@interface ResolutionCenterCreateStepTwoViewController : UIViewController

@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@property (strong, nonatomic) ResolutionCenterCreateResult* result;

@end
