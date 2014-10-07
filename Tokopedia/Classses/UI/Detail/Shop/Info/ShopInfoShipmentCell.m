//
//  ShopInfoShipmentCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopInfoShipmentCell.h"

@implementation ShopInfoShipmentCell

#pragma mark - Factory Method
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ShopInfoShipmentCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    _viewpackage = [NSArray sortViewsWithTagInArray:_viewpackage];
    _labelpackage = [NSArray sortViewsWithTagInArray:_labelpackage];
    _image = [NSArray sortViewsWithTagInArray:_image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
