//
//  ResolutionCenterChooseProblemViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResolutionCenterCreateList.h"

@protocol ResolutionCenterChooseProblemDelegate <NSObject>
@optional
-(void)didSelectProblem:(ResolutionCenterCreateList*)selectedProblem;
@end

@interface ResolutionCenterChooseProblemViewController : UIViewController
@property (strong, nonatomic) NSArray<ResolutionCenterCreateList*>* list_ts;
@property (nonatomic, weak) id<ResolutionCenterChooseProblemDelegate> delegate;
@end
