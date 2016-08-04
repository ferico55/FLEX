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

@interface ResolutionCenterCreateStepTwoViewController : UIViewController

@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@property (strong, nonatomic) NSMutableArray<ResolutionProductList*>* selectedProduct;
@end
