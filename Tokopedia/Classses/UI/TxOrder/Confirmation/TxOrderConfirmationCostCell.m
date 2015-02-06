//
//  TxOrderConfirmationCostCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmationCostCell.h"

@implementation TxOrderConfirmationCostCell

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TxOrderConfirmationCostCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


@end
