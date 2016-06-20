//
//  SearchResultShopCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchResultShopCell.h"

@implementation SearchResultShopCell

- (void)setModelView:(SearchShopModelView *)modelView {
    self.shopName.text = modelView.shopName;
    [self.shopImage setImageWithURL:[NSURL URLWithString:modelView.shopImageUrl]];
    self.shopImage.layer.masksToBounds = YES;
    self.shopImage.layer.cornerRadius = self.shopImage.frame.size.width / 2;
    
    self.shopLocation.text = modelView.shopLocation;
    self.goldBadgeView.hidden = modelView.isGoldShop ? NO : YES;
}

@end
