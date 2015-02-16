//
//  TxOrderConfirmationProductCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_ORDER_CONFIRMATION_PRODUCT_CELL_IDENTIFIER @"TxOrderConfirmationProductCellIdentifier"

@interface TxOrderConfirmationProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productWeightLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;

+(id)newCell;

@end
