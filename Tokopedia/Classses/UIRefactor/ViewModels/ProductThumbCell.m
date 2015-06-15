//
//  ProductThumbCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductThumbCell.h"
#import "ProductModelView.h"

@interface ProductThumbCell()

@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;


+ (id)initCell;

@end

@implementation ProductThumbCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setViewModel:(ProductModelView *)viewModel {

    self.goldShopBadge.hidden = viewModel.isGoldShopProduct ? NO : YES;

    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [self.productImage setContentMode:UIViewContentModeCenter];
    [self.productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.productImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@""]];
    }];
    
}


@end
