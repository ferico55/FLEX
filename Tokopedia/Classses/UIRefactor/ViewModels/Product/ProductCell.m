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
#import "ProductBadge.h"
#import "QueueImageDownloader.h"

@implementation ProductCell{
    QueueImageDownloader* imageDownloader;
}

- (void)setViewModel:(ProductModelView *)viewModel {
    if(imageDownloader == nil){
        imageDownloader = [QueueImageDownloader new];
    }
    
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
    
    self.preorderLabel.hidden = viewModel.isProductPreorder ? NO : YES;
    self.grosirLabel.hidden = viewModel.isWholesale ? NO : YES;
    
    self.preorderPosition.constant = !viewModel.isWholesale ? -42 : 3;
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    
    //all of this is just for badges, dynamic badges
    [_badgesView removeAllPushedView];
    CGSize badgeSize = CGSizeMake(_badgesView.frame.size.height, _badgesView.frame.size.height);
    [_badgesView setOrientation:TKPDStackViewOrientationRightToLeft];
    
    
    NSMutableArray *urls = [NSMutableArray new];
    for(ProductBadge* badge in viewModel.badges){
        [urls addObject:badge.image_url];
    }
    
    [imageDownloader downloadImagesWithUrls:urls onComplete:^(NSArray<UIImage *> *images) {
        for(UIImage *image in images){
            if(image.size.width > 1){
                UIView *badgeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, badgeSize.width, badgeSize.height)];
                UIImageView *badgeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, badgeSize.width, badgeSize.height)];
                badgeImageView.image = image;
                [badgeView addSubview:badgeImageView];
                [_badgesView pushView:badgeView];
            }
        }
    }];
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];

    self.productPrice.text = @"Mulai dari";
    self.productPrice.font = [UIFont fontWithName:@"GothamBook" size:11.0];
    
    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
     self.goldShopBadge.hidden = YES;
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeCenter];
    
    self.preorderLabel.hidden = YES;
    self.grosirLabel.hidden = YES;
    self.locationImage.hidden = YES;
    self.shopLocation.text = nil;
    
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}

@end
