//
//  ProductTableViewCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductCell.h"
#import "ProductModelView.h"
#import "CatalogModelView.h"

@implementation ProductCell

- (void)setViewModel:(ProductModelView *)viewModel {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:12],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                 };
    
    self.productName.attributedText = [[NSAttributedString alloc] initWithString:viewModel.productName attributes:attributes];
    
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    [self.shopLocation setText:viewModel.shopLocation];
    self.grosirLabel.layer.masksToBounds = YES;
    self.preorderLabel.layer.masksToBounds = YES;
    
    if(!viewModel.productShop || [viewModel.productShop isEqualToString:@"0"]) {
        [self.productShop setHidden:YES];
    }
    
    self.goldShopBadge.hidden = viewModel.isGoldShopProduct? NO : YES;
    self.luckyBadgePosition.constant = viewModel.isGoldShopProduct ? 1 : -15;
    self.preorderLabel.hidden = viewModel.isProductPreorder ? NO : YES;
    self.grosirLabel.hidden = viewModel.isWholesale ? NO : YES;
    
    self.preorderPosition.constant = !viewModel.isWholesale ? -42 : 3;
    
    
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    
    [self.luckyMerchantBadge setImageWithURL:[NSURL URLWithString:viewModel.luckyMerchantImageURL]];
    [self.luckyMerchantBadge setContentMode:UIViewContentModeScaleAspectFill];
    
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];

    self.productPrice.text = @"Mulai dari";
    self.productPrice.font = [UIFont fontWithName:@"GothamBook" size:11.0];
    
    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
     self.goldShopBadge.hidden = YES;
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [self.productImage setContentMode:UIViewContentModeCenter];
    
    self.preorderLabel.hidden = YES;
    self.grosirLabel.hidden = YES;
    self.locationImage.hidden = YES;
    self.shopLocation.text = nil;
    
}

@end
