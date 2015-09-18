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

@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintGoldBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSpaceGoldBadge;


+ (id)initCell;

@end

@implementation ProductThumbCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setViewModel:(ProductModelView *)viewModel {

    self.goldShopBadge.hidden = viewModel.isGoldShopProduct ? NO : YES;
    
    if (self.goldShopBadge.hidden == YES) {
        _constraintGoldBadge.constant = 0;
        _constraintSpaceGoldBadge.constant = 0;
    }

    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
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
    [self.goldShopBadge setHidden:YES];
    
    if (self.goldShopBadge.hidden == YES) {
        _constraintGoldBadge.constant = 0;
        _constraintSpaceGoldBadge.constant = 0;
    }
    
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
