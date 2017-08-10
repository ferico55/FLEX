//
//  ShopInfoAddressCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopInfoAddressCell.h"

@implementation ShopInfoAddressCell

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ShopInfoAddressCell" owner:nil options:0];
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
