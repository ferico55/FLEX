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
#import "ProductBadge.h"
#import "QueueImageDownloader.h"

@implementation ProductThumbCell {
    QueueImageDownloader* imageDownloader;
}

- (void)setViewModel:(ProductModelView *)viewModel {
    if(imageDownloader == nil){
        imageDownloader = [QueueImageDownloader new];
    }
    
    self.productName.font = [UIFont smallThemeMedium];
    self.productName.text = viewModel.productName?:@"";
    self.productPrice.text = viewModel.productPrice;
    self.shopName.text = viewModel.productShop;
    self.shopLocation.text = viewModel.shopLocation;
    self.preorderLabel.hidden = viewModel.isProductPreorder ? NO : YES;
    self.grosirLabel.hidden = viewModel.isWholesale ? NO : YES;
    self.grosirIconLocation.constant = viewModel.isProductPreorder ? 7 : -50;
    self.luckyIconLocation.constant = viewModel.isGoldShopProduct ? 7 : -19;
    [_productName setLineBreakMode:NSLineBreakByTruncatingTail];
    
    self.grosirLabel.layer.masksToBounds = YES;
    self.preorderLabel.layer.masksToBounds = YES;

    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    
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
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    
    self.preorderLabel.hidden = YES;
    self.grosirLabel.hidden = YES;
    self.locationIcon.hidden = YES;
    self.shopLocation.text = nil;

    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.productPrice.text = @"Mulai dari :";
    self.productPrice.font = [UIFont microTheme];
    
    self.productName.numberOfLines = 2;
    self.productName.font = [UIFont smallThemeMedium];
    self.productName.text = viewModel.catalogName;
    
    self.productPriceWidthConstraint.constant = -50;
    [self.shopName setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}

@end
