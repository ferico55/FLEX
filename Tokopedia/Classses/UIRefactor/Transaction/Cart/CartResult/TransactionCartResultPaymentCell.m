//
//  TransactionCartResultPaymentCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartResultPaymentCell.h"

@implementation TransactionCartResultPaymentCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TransactionCartResultPaymentCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)expandingButton:(id)sender {
    [_delegate didExpand];
}

@end
