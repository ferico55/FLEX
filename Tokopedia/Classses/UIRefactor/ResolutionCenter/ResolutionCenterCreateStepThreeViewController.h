//
//  ResolutionCenterCreateStepThreeViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResolutionCenterCreateData.h"
#import "ResolutionCenterCreateResult.h"
#import "ResolutionCenterCreateViewController.h"

@protocol ResolutionCenterCreateStepThreeDelegate <NSObject>
- (void) didFinishCreateComplainInStepThree;
@end
@interface ResolutionCenterCreateStepThreeViewController : UIViewController
@property (strong, nonatomic) ResolutionCenterCreateResult* result;
@property BOOL product_is_received;
-(void)submitCreateResolution;
-(void)submitEditResolution;
@property (weak, nonatomic) id<ResolutionCenterCreateStepThreeDelegate> delegate;

@end
