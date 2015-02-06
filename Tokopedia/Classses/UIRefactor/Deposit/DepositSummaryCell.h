//
//  DepositSummaryCell.h
//  Tokopedia
//
//  Created by Tokopedia on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepositSummaryCell : UITableViewCell

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;
@property (strong, nonatomic) NSIndexPath *indexpath;

@property (weak, nonatomic) IBOutlet UILabel *depositNotes;
@property (weak, nonatomic) IBOutlet UILabel *currentSaldo;
@property (weak, nonatomic) IBOutlet UILabel *depositAmount;
@property (weak, nonatomic) IBOutlet UILabel *withdrawalTime;


@end
