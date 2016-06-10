//
//  ProductThumbCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductThumbCell.h"
#import "ProductModelView.h"
#import "CatalogModelView.h"

@implementation ProductThumbCell

- (void)setViewModel:(ProductModelView *)viewModel {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:12],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                 };
    
    self.productName.attributedText = [[NSAttributedString alloc] initWithString:viewModel.productName attributes:attributes];
    self.productPrice.text = viewModel.productPrice;
    self.shopName.text = viewModel.productShop;
    self.shopLocation.text = viewModel.shopLocation;
    self.preorderLabel.hidden = viewModel.isProductPreorder ? NO : YES;
    self.grosirLabel.hidden = viewModel.isWholesale ? NO : YES;
    self.goldShopBadge.hidden = viewModel.isGoldShopProduct ? NO : YES;
    self.grosirIconLocation.constant = viewModel.isProductPreorder ? 7 : -50;
    self.luckyIconLocation.constant = viewModel.isGoldShopProduct ? 7 : -19;
    
    self.grosirLabel.layer.masksToBounds = YES;
    self.preorderLabel.layer.masksToBounds = YES;

    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.luckyMerchantBadge setImageWithURL:[NSURL URLWithString:viewModel.luckyMerchantImageURL]];
    [self.luckyMerchantBadge setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.goldShopBadge setHidden:YES];

    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    
    self.preorderLabel.hidden = YES;
    self.grosirLabel.hidden = YES;
    self.locationIcon.hidden = YES;
    self.shopLocation.text = nil;

    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.productPrice.text = @"Mulai dari :";
    self.productPrice.font = [UIFont fontWithName:@"GothamBook" size:11.0];
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary* catalogNameAtt = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:12],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                     };
    self.productName.numberOfLines = 2;
    self.productName.attributedText = [[NSAttributedString alloc] initWithString:viewModel.catalogName attributes:catalogNameAtt];
    
    self.productPriceWidthConstraint.constant = -50;
    [self.shopName setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
}


@end
