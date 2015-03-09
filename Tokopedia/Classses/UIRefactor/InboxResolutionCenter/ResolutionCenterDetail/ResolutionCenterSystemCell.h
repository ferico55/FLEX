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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ResolutionCenterSystemCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ResolutionCenterSystemCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UIView *twoButtonView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *twoButtons;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *markView;

+(id)newCell;
@property NSIndexPath *indexPath;

- (void)hideAllViews;

@end
