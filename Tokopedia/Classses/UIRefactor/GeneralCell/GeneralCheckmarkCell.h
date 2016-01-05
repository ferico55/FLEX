//
//  GeneralCheckmarkCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GENERAL_CHECKMARK_CELL_IDENTIFIER @"GeneralCheckmarkCellIdentifier"

@interface GeneralCheckmarkCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cellLableLeadingConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *iconPinPoint;

+(id)newcell;

@end
