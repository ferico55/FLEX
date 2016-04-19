//
//  EditShopImageViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopImageViewCell.h"

@implementation EditShopImageViewCell

- (void)awakeFromNib {
    self.shopImageView.layer.cornerRadius = self.shopImageView.frame.size.width / 2;
    self.shopImageView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    self.shopImageView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
