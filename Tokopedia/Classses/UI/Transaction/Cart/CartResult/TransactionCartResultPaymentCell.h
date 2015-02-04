//
//  TransactionCartResultPaymentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_CART_PAYMENT_CELL_IDENTIDIER @"TransactionCartResultPaymentCellCellIdentifier"

@interface TransactionCartResultPaymentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;

+ (id)newcell;

@end
