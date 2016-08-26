//
//  ResolutionCenterChooseSolutionViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResolutionCenterCreatePOSTFormSolution.h"
@protocol ResolutionCenterChooseSolutionDelegate <NSObject>
@optional
-(void)didSelectSolution:(ResolutionCenterCreatePOSTFormSolution*)selectedSolution;
@end

@interface ResolutionCenterChooseSolutionViewController : UIViewController
@property (strong, nonatomic) NSArray<ResolutionCenterCreatePOSTFormSolution*>* formSolutions;
@property (nonatomic, weak) id<ResolutionCenterChooseSolutionDelegate> delegate;
@end
