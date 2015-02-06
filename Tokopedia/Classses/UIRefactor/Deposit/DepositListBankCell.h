//
//  DepositListBankCell.h
//  Tokopedia
//
//  Created by Tokopedia on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepositListBankCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UIImageView *isChecked;

+(id)newcell;

@end
