//
//  TxOrderStatusCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_ORDER_STATUS_CELL_IDENTIFIER @"TxOrderStatusCellIdentifier"


#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderStatusCellDelegate <NSObject>
@required
- (void)statusDetailAtIndexPath:(NSIndexPath*)indexPath;
- (void)confirmDeliveryAtIndexPath:(NSIndexPath*)indexPath;
- (void)trackOrderAtIndexPath:(NSIndexPath*)indexPath;
- (void)reOrderAtIndexPath:(NSIndexPath*)indexPath;
- (void)complainAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface TxOrderStatusCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderStatusCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderStatusCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *shopProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *cancelAutomaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;

@property (weak, nonatomic) IBOutlet UIView *threeButtonsView;
@property (weak, nonatomic) IBOutlet UIView *twoButtonsView;
@property (weak, nonatomic) IBOutlet UIView *oneButtonView;
@property (weak, nonatomic) IBOutlet UIView *oneButtonReOrderView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;

@property (nonatomic) NSInteger deadlineProcessDayLeft;

@property NSIndexPath *indexPath;

+(id)newCell;
- (void)hideAllButton;

@end
