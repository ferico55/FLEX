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
#import "ProductBadge.h"
#import "ProductLabel.h"
#import "Tokopedia-Swift.h"
#import "QueueImageDownloader.h"


@implementation ProductSingleViewCell{
    QueueImageDownloader* imageDownloader;
}

- (void)setViewModel:(ProductModelView *)viewModel {
    if(imageDownloader == nil){
        imageDownloader = [QueueImageDownloader new];
    }
    
    [self.productName setText:viewModel.productName];
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    
    self.shopLocation.text = viewModel.shopLocation;
    self.grosirPosition.constant = viewModel.isProductPreorder ? 10 : -64;

    [self.productInfoLabel setText:[NSString stringWithFormat:@"%@ Diskusi - %@ Ulasan", viewModel.productTalk, viewModel.productReview]];
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
    
    [self setBadges:viewModel.badges];
    [self setLabels:viewModel.labels];
}

- (void)setLabels:(NSArray<ProductLabel*>*) labels {
    for(UIView* subview in _labelsView.arrangedSubviews) {
        [_labelsView removeArrangedSubview:subview];
    }
    
    _labelsView.alignment = OAStackViewAlignmentFill;
    _labelsView.spacing = 2;
    _labelsView.axis = UILayoutConstraintAxisHorizontal;
    _labelsView.distribution = OAStackViewDistributionEqualSpacing;
    
    for(ProductLabel* productLabel in labels) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [NSString stringWithFormat:@" %@  ", productLabel.title];
        label.backgroundColor  = [UIColor fromHexString:productLabel.color];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1.0;
        label.layer.borderColor =  [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor lightGrayColor].CGColor : [UIColor whiteColor].CGColor;
        label.textColor = [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor lightGrayColor] : [UIColor whiteColor];
        label.font = [UIFont microTheme];
        
        [label sizeToFit];
        
        [_labelsView addArrangedSubview:label];
    }
}

- (void)setBadges:(NSArray<ProductBadge*>*)badges {
    //all of this is just for badges, dynamic badges
    [_badgesView removeAllPushedView];
    CGSize badgeSize = CGSizeMake(_badgesView.frame.size.height, _badgesView.frame.size.height);
    [_badgesView setOrientation:TKPDStackViewOrientationRightToLeft];
    
    NSMutableArray *urls = [NSMutableArray new];
    for(ProductBadge* badge in badges){
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
    self.productPriceWidthConstraint.constant = -50;
    self.productPrice.font = [UIFont microTheme];
    
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.catalogPriceLabel.hidden = NO;
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
    
    self.locationIcon.hidden = YES;
    self.shopLocation.text = nil;
    self.productInfoLabel.hidden = YES;
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}
@end
