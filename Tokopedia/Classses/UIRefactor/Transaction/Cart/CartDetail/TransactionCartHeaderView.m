//
//  TransactionCartHeaderView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartHeaderView.h"

@implementation TransactionCartHeaderView

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

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_delegate deleteTransactionCartHeaderView:self atSection:_section];
}

@end
