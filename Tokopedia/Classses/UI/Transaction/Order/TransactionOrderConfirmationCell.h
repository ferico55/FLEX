//
//  TransactionOrderConfirmationCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_ORDER_CONFIRMATION_CELL_IDENTIFIER @"TransactionOrderConfirmationCellIdentifier"

@interface TransactionOrderConfirmationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *totalInvoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadlineDateLabel;

+ (id)newcell;

@end
