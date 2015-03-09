//
//  TransactionCartResultCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSACTION_CART_RESULT_CELL_IDENTIFIER @"TransactionCartResultCellIdentifier"

@interface TransactionCartResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *bankBranchLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoBankImageView;

+ (id)newcell;

@end
