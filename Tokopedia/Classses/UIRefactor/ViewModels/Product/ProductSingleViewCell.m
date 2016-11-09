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
    
    for(UIView* subview in _badgesView.arrangedSubviews) {
        [_badgesView removeArrangedSubview:subview];
    }
    
    _badgesView.spacing = 2;
    _badgesView.axis = UILayoutConstraintAxisHorizontal;
    _badgesView.distribution = OAStackViewDistributionFillEqually;
    _badgesView.alignment = OAStackViewAlignmentCenter;
    
    for(ProductBadge* productBadge in badges) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setImageWithURL:[NSURL URLWithString:productBadge.image_url]];
        
        if(imageView.image.size.width > 1) {
            [_badgesView addArrangedSubview:imageView];
            
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(_badgesView.mas_height);
                make.height.equalTo(_badgesView.mas_height);
            }];
        }
    }
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
