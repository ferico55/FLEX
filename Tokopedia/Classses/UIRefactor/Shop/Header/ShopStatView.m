//
//  ShopStatView.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopStatView.h"

@implementation ShopStatView

#pragma mark - Factory Method

+(id)newView
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
