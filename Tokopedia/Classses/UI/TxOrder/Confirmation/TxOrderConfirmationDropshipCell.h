//
//  TxOrderConfirmationDropshipCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DROPSHIP_CELL_IDENTIFIER @"TxOrderConfirmationDropshipCellIdentifier"

@interface TxOrderConfirmationDropshipCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dropshipNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropshipPhoneLabel;

+ (id)newCell;

@end
