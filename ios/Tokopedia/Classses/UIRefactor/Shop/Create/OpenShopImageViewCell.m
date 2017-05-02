//
//  OpenShopImageViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 4/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "OpenShopImageViewCell.h"

@implementation OpenShopImageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.shopImageView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    self.shopImageView.layer.borderWidth = 1;
    self.shopImageView.layer.cornerRadius = self.shopImageView.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
