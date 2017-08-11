//
//  GeneralProductCollectionViewCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 5/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralProductCollectionViewCell.h"

@implementation GeneralProductCollectionViewCell

- (void)setViewModel:(ProductModelView *)productModelView
{
    self.productPrice.text = productModelView.productPrice;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:productModelView.productName];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [productModelView.productName length])];
    self.productName.attributedText = attributedString;
    self.productName.lineBreakMode = NSLineBreakByTruncatingTail;
    self.productShop.text = productModelView.productShop?:@"";
    if(productModelView.isGoldShopProduct) {
        self.goldShopBadge.hidden = NO;
    } else {
        self.goldShopBadge.hidden = YES;
    }
    
    
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:productModelView.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *thumb = self.productImage;
    thumb.image = nil;
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
        [thumb setContentMode:UIViewContentModeScaleAspectFill];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
}
@end
