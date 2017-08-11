//
//  CatalogSpecificationCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogSpecificationCell.h"

@interface CatalogSpecificationCell ()

@property (weak, nonatomic) IBOutlet UIView *borderTop;
@property (weak, nonatomic) IBOutlet UIView *bottomBorder;

@end

@implementation CatalogSpecificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.valueLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)hideTopBorder:(BOOL)hide
{
    _borderTop.hidden = hide;
}

- (void)hideBottomBorder:(BOOL)hide
{
    _bottomBorder.hidden = hide;
}

@end
