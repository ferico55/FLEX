//
//  EditShopTypeViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopTypeViewCell.h"

@implementation EditShopTypeViewCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)showsGoldMerchantBadge {
    self.goldMerchantBadgeView.hidden = NO;
    self.regularMerchantLabel.hidden = YES;
}

@end
