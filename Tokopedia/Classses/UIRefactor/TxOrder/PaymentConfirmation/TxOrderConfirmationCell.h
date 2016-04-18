//
//  TxOrderConfirmationCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_ORDER_CONFIRMATION_CELL_IDENTIFIER @"TxOrderConfirmationCellIdentifier"
#pragma mark - Transaction Order Confirmation Delegate
@protocol TxOrderConfirmationCellDelegate <NSObject>
@required
-(void)shouldCancelOrderAtIndexPath:(NSIndexPath*)indexPath;
-(void)shouldConfirmOrderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TxOrderConfirmationCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<TxOrderConfirmationCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UILabel *totalInvoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadlineDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
@property (weak, nonatomic) IBOutlet UIView *frameView;
@property (weak, nonatomic) IBOutlet UIButton *cancelConfirmationButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmationButton;

@property (strong, nonatomic)NSIndexPath *indexPath;

+ (id)newcell;

@end
