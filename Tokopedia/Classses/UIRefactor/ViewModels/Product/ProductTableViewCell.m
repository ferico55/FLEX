//
//  ProductTableViewCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "ProductModelView.h"


@implementation ProductTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setViewModel:(ProductModelView *)viewModel {
    [self.productName setText:viewModel.productName];
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

    [self.productThumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productThumb setImage:image];
        [self.productThumb setContentMode:UIViewContentModeScaleAspectFill];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productThumb setImage:[UIImage imageNamed:@""]];
    }];

}

@end
