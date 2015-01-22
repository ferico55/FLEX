//
//  ChooseProductCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ChooseProductCell.h"

@implementation ChooseProductCell

- (void)awakeFromNib {
    self.checkBoxImageView.layer.cornerRadius = self.checkBoxImageView.layer.frame.size.width /2;
    self.checkBoxImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.checkBoxImageView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end