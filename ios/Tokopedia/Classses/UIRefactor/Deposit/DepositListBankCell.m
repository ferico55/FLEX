//
//  DepositListBankCell.m
//  Tokopedia
//
//  Created by Tokopedia on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DepositListBankCell.h"

@implementation DepositListBankCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSLog( @"Cell loading" );
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"DepositListBankCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
