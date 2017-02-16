//
//  ShipmentStatusCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderTransaction;

@protocol ShipmentStatusCellDelegate <NSObject>

- (void)didTapTrackButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath;
- (void)didTapReceiptButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath;
- (void)didTapStatusAtIndexPath:(NSIndexPath *)indexPath;
- (void)didTapUserAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ShipmentStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *buyerProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *buyerNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateFinishLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;

@property (weak, nonatomic) IBOutlet UIView *twoButtonsView;
@property (weak, nonatomic) IBOutlet UIView *oneButtonView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) id<ShipmentStatusCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet OrderTransaction *order;

- (void)hideDayLeftInformation;
- (void)showTrackButtonOnTap:(void(^)(OrderTransaction *))onTap;
- (void)showRetryButtonOnTap:(void(^)(OrderTransaction *))onTap;
- (void)showEditResiButtonOnTap:(void(^)(OrderTransaction *))onTap;
- (void)showAskBuyerButtonOnTap:(void (^)(OrderTransaction *))onTap;
- (void)hideAllButton;
- (void)setStatusLabelText:(NSString *)text;

@end
