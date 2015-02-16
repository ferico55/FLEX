//
//  TxOrderConfirmedBankCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BANK_CELL_IDENTIFIER @"TxOrderConfirmedBankCellIdentifier"

@interface TxOrderConfirmedBankCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nomorRekLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverNomorRekLabel;

+(id)newCell;

@end
