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


@property (nonatomic, weak) IBOutlet id<TxOrderConfirmedCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UIButton *totalInvoiceButton;

@property (strong, nonatomic) NSIndexPath *indexPath;

+(id)newCell;

@end
