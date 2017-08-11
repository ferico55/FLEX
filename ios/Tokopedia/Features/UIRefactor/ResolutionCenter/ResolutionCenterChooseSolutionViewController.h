//
//  ResolutionCenterChooseSolutionViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditSolution;

@protocol ResolutionCenterChooseSolutionDelegate <NSObject>
@optional
-(void)didSelectSolution:(EditSolution*)selectedSolution;
@end

@interface ResolutionCenterChooseSolutionViewController : UIViewController
@property (strong, nonatomic) NSArray<EditSolution*>* formSolutions;
@property (nonatomic, weak) id<ResolutionCenterChooseSolutionDelegate> delegate;
@end
