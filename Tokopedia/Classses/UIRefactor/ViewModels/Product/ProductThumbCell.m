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

@interface ProductThumbCell()

@end

@implementation ProductThumbCell

- (void)awakeFromNib {
    // Initialization code
}

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

    

    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setImage:image];
        [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];
    
    UIImageView *thumb =self.luckyMerchantBadge;
    thumb.image = nil;
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.luckyMerchantImageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.luckyMerchantBadge setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        thumb.image = image;
        thumb.contentMode = UIViewContentModeScaleAspectFill;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        thumb.image = [UIImage imageNamed:@""];
    }];
    
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.goldShopBadge setHidden:YES];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.productImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];
    
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
