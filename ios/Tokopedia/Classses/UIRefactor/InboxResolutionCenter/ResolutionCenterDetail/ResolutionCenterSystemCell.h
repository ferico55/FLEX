//
//  ResolutionCenterSystemCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RESOLUTION_CENTER_SYSTEM_CELL_IDENTIFIER @"ResolutionCenterSystemCellIdentifier"

@protocol ResolutionCenterSystemCellDelegate <NSObject>
@required
- (void)tapCellButton:(UIButton*)sender atIndexPath:(NSIndexPath*)indexPath;

@end

@interface ResolutionCenterSystemCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<ResolutionCenterSystemCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UIView *twoButtonView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *twoButtons;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *markView;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIView *oneButtonView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneButtonConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twoButtonConstraintHeight;
@property (weak, nonatomic) IBOutlet UIView *titleView;

+(id)newCell;
@property NSIndexPath *indexPath;

- (void)hideAllViews;

@end
