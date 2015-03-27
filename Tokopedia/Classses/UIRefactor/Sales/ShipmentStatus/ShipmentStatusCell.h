//
//  ShipmentStatusCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

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

- (void)hideDayLeftInformation;
- (void)showTrackButton;
- (void)showAllButton;
- (void)hideAllButton;
- (void)setStatusLabelText:(NSString *)text;

@end