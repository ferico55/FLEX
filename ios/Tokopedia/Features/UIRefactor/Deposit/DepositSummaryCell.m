//
//  DepositSummaryCell.m
//  Tokopedia
//
//  Created by Tokopedia on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DepositSummaryCell.h"

@implementation DepositSummaryCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"DepositSummaryCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

@end
