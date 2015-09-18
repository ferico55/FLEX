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

@interface ProductSingleViewCell()

@property (strong, nonatomic) IBOutlet UILabel *productInfoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productShop;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintGoldBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSpaceGoldBadge;

@end

@implementation ProductSingleViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setViewModel:(ProductModelView *)viewModel {
    [self.productName setText:viewModel.productName];
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    [self.goldShopBadge setHidden:viewModel.isGoldShopProduct ? NO : YES];
    
    if (self.goldShopBadge.hidden == YES) {
        _constraintGoldBadge.constant = 0;
        _constraintSpaceGoldBadge.constant = 0;
    }
    
    [self.productInfoLabel setText:[NSString stringWithFormat:@"%@ Diskusi - %@ Ulasan", viewModel.productTalk, viewModel.productReview]];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.productImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.luckyMerchantImageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.luckyMerchantBadge setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.luckyMerchantBadge setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.luckyMerchantBadge setImage:[UIImage imageNamed:@""]];
    }];
    
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];
    [self.productPrice setText:viewModel.catalogPrice];
    [self.productInfoLabel setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
    self.goldShopBadge.hidden = YES;
    
    if (self.goldShopBadge.hidden == YES) {
        _constraintGoldBadge.constant = 0;
        _constraintSpaceGoldBadge.constant = 0;
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setImage:image];
        self.productImage.backgroundColor = [UIColor whiteColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.luckyMerchantImageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.luckyMerchantBadge setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.luckyMerchantBadge setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.luckyMerchantBadge setImage:[UIImage imageNamed:@""]];
    }];
}

@end
