//
//  ShopInfoPaymentCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopInfoPaymentCell.h"

@implementation ShopInfoPaymentCell

#pragma mark - Factory Method
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ShopInfoPaymentCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
