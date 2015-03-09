//
//  TxOrderConfirmationDetailHeaderView.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmationDetailHeaderView.h"

@implementation TxOrderConfirmationDetailHeaderView

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

@end
