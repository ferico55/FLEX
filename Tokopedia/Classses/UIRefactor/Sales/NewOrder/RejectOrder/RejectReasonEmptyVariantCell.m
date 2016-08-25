//
//  RejectReasonEmptyVariantCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonEmptyVariantCell.h"

@implementation RejectReasonEmptyVariantCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setViewModel:(ProductModelView *)viewModel {
    _emptyStockLabel.layer.cornerRadius = 4;
    
    [_productName setText:viewModel.productName];
    [_productPrice setText:viewModel.productPriceIDR];
    
    //to make the "stok kosong" label fit next to price label
    [_productPrice sizeToFit];
    
    [_emptyStockLabel setHidden:viewModel.isProductBuyAble];
    
    [_productDescription setText:viewModel.productDescription];
    
    [_productImage setContentMode:UIViewContentModeScaleAspectFill];
    [_productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl]
                  placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)changeDescriptionButtonTapped:(id)sender {
    [self.delegate tableViewCell:self changeProductDescriptionAtIndexPath:_indexPath];
}

@end
