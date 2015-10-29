//
//  AlertListBankCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/28/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TableViewCell.h"

@interface AlertListBankCell : TableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextCellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *subDetailCellLabel;

+ (id)newcell;

@end
