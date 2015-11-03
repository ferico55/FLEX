//
//  ResolutionCenterDetailCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationViewModel.h"

#define RESOLUTION_CENTER_DETAIL_CELL_IDENTIFIER @"ResolutionCenterDetailCellIdentifier"

#pragma mark - Transaction Cart Payment Delegate
@protocol ResolutionCenterDetailCellDelegate <NSObject>
@required
- (void)tapCellButton:(UIButton*)sender atIndexPath:(NSIndexPath*)indexPath;
- (void)goToShopOrProfileIndexPath:(NSIndexPath *)indexPath;
- (void)goToImageViewerIndex:(NSInteger)index atIndexPath:(NSIndexPath*)indexPath;
- (void)goToImageViewerImages:(NSArray*)images atIndexImage:(NSInteger)index atIndexPath:(NSIndexPath*)indexPath;

@end

@interface ResolutionCenterDetailCell : UITableViewCell

@property (nonatomic, weak) id<ResolutionCenterDetailCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *buyerView;
@property (weak, nonatomic) IBOutlet UILabel *buyerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UIView *twoButtonView;
@property (weak, nonatomic) IBOutlet UIView *oneButtonView;
@property (weak, nonatomic) IBOutlet UIView *atachmentView;
@property (weak, nonatomic) IBOutlet UILabel *markAttachmentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buyerProfileImageView;
@property (weak, nonatomic) IBOutlet UIView *photosView;
@property (weak, nonatomic) IBOutlet UIButton *btnReputation;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *borders;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachmentImages;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *twoButtons;

@property (weak, nonatomic) IBOutlet UIView *markView;

@property (nonatomic) BOOL isMark;
@property (nonatomic) BOOL isShowAttachment;
@property NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twobuttonConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneButtonConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;

+ (id)newCell;
- (void)hideAllViews;
- (void)setViewModel:(ConversationViewModel *)viewModel;

@end