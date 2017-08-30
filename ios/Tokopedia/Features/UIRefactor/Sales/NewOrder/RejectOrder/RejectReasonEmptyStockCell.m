//
//  RejectReasonEmptyStockCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonEmptyStockCell.h"
@implementation RejectReasonEmptyStockCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setViewModel:(ProductModelView *)viewModel {
    _stokKosongLabel.layer.cornerRadius = 4;
    _stokKosongLabel.clipsToBounds = YES;
    
    [_productName setText:viewModel.productName];
    [_productPrice setText:viewModel.productPriceIDR];
    
    //to make the "stok kosong" label fit next to price label
    [_productPrice sizeToFit];
    
    [_stokKosongLabel setHidden:viewModel.isProductBuyAble];
    
    [_productImage setContentMode:UIViewContentModeScaleAspectFill];
    [_productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl]
                  placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected){
        [_checkImage setImage:[UIImage imageNamed:@"icon_check_green"]];
        [_stokKosongLabel setHidden:NO];
    }else{
        [_checkImage setImage:[UIImage imageNamed:@"icon_circle.png"]];
        [_stokKosongLabel setHidden:YES];
    }
}

@end
