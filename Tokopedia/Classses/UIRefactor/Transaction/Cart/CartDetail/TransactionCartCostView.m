//
//  TransactionCartCostView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartCostView.h"
#import "AlertInfoView.h"

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
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info Biaya Tambahan";
    alertInfo.detailText = @"Biaya tambahan termasuk biaya asuransi dan biaya administrasi pengiriman";
    [alertInfo show];
}

@end
