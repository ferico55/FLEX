//
//  TxOrderConfirmedCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONFIRMED_CELL_IDENTIFIER @"TxOrderConfirmedCellIdentifier"

#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderConfirmedCellDelegate <NSObject>
@required
- (void)didTapInvoiceButton:(UIButton*)button atIndexPath:(NSIndexPath*)indexPath;

@end

@interface TxOrderConfirmedCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderConfirmedCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderConfirmedCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UIButton *totalInvoiceButton;

+(id)newCell;

@end
