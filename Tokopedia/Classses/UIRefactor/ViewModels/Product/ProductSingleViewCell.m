//
//  ProductSingleViewCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductSingleViewCell.h"

#import "ProductCell.h"
#import "ProductModelView.h"
#import "CatalogModelView.h"


@implementation ProductSingleViewCell

- (void)setViewModel:(ProductModelView *)viewModel {
    [self.productName setText:viewModel.productName];
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    [self.goldShopBadge setHidden:viewModel.isGoldShopProduct ? NO : YES];
    
    self.luckyIconPosition.constant = viewModel.isGoldShopProduct ? 10 : -20;
    self.shopLocation.text = viewModel.shopLocation;
    self.grosirLabel.layer.masksToBounds = YES;
    self.preorderLabel.layer.masksToBounds = YES;
    self.preorderLabel.hidden = viewModel.isProductPreorder ? NO : YES;
    self.grosirLabel.hidden = viewModel.isWholesale ? NO : YES;
    self.grosirPosition.constant = viewModel.isProductPreorder ? 10 : -64;

    [self.productInfoLabel setText:[NSString stringWithFormat:@"%@ Diskusi - %@ Ulasan", viewModel.productTalk, viewModel.productReview]];
    
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    
    [self.luckyMerchantBadge setImageWithURL:[NSURL URLWithString:viewModel.luckyMerchantImageURL]];
    [self.luckyMerchantBadge setContentMode:UIViewContentModeScaleAspectFill];
    
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];
    
    self.productPrice.text = @"Mulai dari";
    self.productPriceWidthConstraint.constant = -50;
    self.productPrice.font = [UIFont fontWithName:@"GothamBook" size:11.0];
    
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.catalogPriceLabel.hidden = NO;
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [self.productImage setContentMode:UIViewContentModeCenter];
    
    self.preorderLabel.hidden = YES;
    self.grosirLabel.hidden = YES;
    self.locationIcon.hidden = YES;
    self.shopLocation.text = nil;
    self.productInfoLabel.hidden = YES;
}

@end
