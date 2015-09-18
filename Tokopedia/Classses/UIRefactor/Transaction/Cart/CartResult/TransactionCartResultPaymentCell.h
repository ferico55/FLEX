//
//  TransactionCartResultPaymentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_CART_PAYMENT_CELL_IDENTIDIER @"TransactionCartResultPaymentCellCellIdentifier"

@protocol PaymentCellDelegate <NSObject>
@required
- (void)didExpand;
@end

@interface TransactionCartResultPaymentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet id<PaymentCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *detailPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UIButton *expandingButton;

+ (id)newcell;

@end
