//
//  RejectReasonWrongPriceCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonWrongPriceCell.h"

@implementation RejectReasonWrongPriceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setViewModel:(ProductModelView *)viewModel{
    _emptyStockLabel.layer.cornerRadius = 4;
    [_productName setText:viewModel.productName];
    [_productPrice setText:viewModel.productPriceIDR];
    
    //to make the "stok kosong" label fit next to price label
    //[_productPrice sizeToFit];
    
    [_productWeight setText:viewModel.productTotalWeight];
    
    [_emptyStockLabel setHidden:viewModel.isProductBuyAble];
    
    [_productImage setContentMode:UIViewContentModeScaleAspectFill];
    [_productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl]
                  placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)changePriceButtonTapped:(id)sender {
    [self.delegate tableViewCell:self changeProductPriceAtIndexPath:_indexPath];
}

@end
