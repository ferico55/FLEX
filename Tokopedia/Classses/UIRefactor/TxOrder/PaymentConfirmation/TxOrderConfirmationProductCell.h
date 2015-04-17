//
//  TxOrderConfirmationProductCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_ORDER_CONFIRMATION_PRODUCT_CELL_IDENTIFIER @"TxOrderConfirmationProductCellIdentifier"

@protocol TxOrderConfirmationProductCellDelegate <NSObject>
@required
- (void)didTapImageViewAtIndexPath:(NSIndexPath*)indexPath;
- (void)didTapProductAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface TxOrderConfirmationProductCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderConfirmationProductCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderConfirmationProductCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;

+(id)newCell;

@property NSIndexPath *indexPath;

@end
