//
//  TransactionCartCostView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartCostView.h"

@implementation TransactionCartCostView

#pragma mark - Factory Method
+ (id)newview
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id view in views) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    return nil;
}
- (IBAction)tap:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Biaya tambahan termasuk biaya asuransi dan biaya administrasi pengiriman" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
