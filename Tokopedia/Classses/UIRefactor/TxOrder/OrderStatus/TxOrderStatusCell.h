//
//  TxOrderStatusCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TextMenu;

#define TRANSACTION_ORDER_STATUS_CELL_IDENTIFIER @"TxOrderStatusCellIdentifier"


#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderStatusCellDelegate <NSObject>
@required
- (void)statusDetailAtIndexPath:(NSIndexPath*)indexPath;
- (void)confirmDeliveryAtIndexPath:(NSIndexPath*)indexPath;
- (void)trackOrderAtIndexPath:(NSIndexPath*)indexPath;
- (void)reOrderAtIndexPath:(NSIndexPath*)indexPath;
- (void)complainAtIndexPath:(NSIndexPath*)indexPath;
- (void)goToComplaintDetailAtIndexPath:(NSIndexPath *)indexPath;

- (void)goToInvoiceAtIndexPath:(NSIndexPath *)indexPath;
- (void)goToShopAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TxOrderStatusCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<TxOrderStatusCellDelegate> delegate;
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

@property (weak, nonatomic) IBOutlet TextMenu *statusTv;
//@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *twoButtons;

@property (nonatomic) NSInteger deadlineProcessDayLeft;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonConstraintHeight;


@property NSIndexPath *indexPath;

+(id)newCell;
- (void)hideAllButton;

@end
