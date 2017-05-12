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
#import "ProductLabel.h"
#import "QueueImageDownloader.h"
#import "Tokopedia-Swift.h"
#import "StarsRateView.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface ProductCell()
@property (strong, nonatomic) IBOutlet StarsRateView *starsRateView;
@property (strong, nonatomic) IBOutlet UIView *ratingContainerView;
@property (strong, nonatomic) IBOutlet UILabel *totalReviewLabel;
@property (strong, nonatomic) NSString *productId;
@end

@implementation ProductCell{
    QueueImageDownloader* imageDownloader;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_shopLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_badgesView.mas_leading);
    }];
}

- (void)setViewModel:(ProductModelView *)viewModel {
    if(imageDownloader == nil){
        imageDownloader = [QueueImageDownloader new];
    }

    self.productName.font = [UIFont smallThemeMedium];
    self.productName.text = viewModel.productName?:@"";
    
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    [self.shopLocation setText:viewModel.shopLocation];

    if(!viewModel.productShop || [viewModel.productShop isEqualToString:@"0"]) {
        [self.productShop setHidden:YES];
    }
    
    self.preorderPosition.constant = !viewModel.isWholesale ? -42 : 3;
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    

    [self setBadges:viewModel.badges];
    [self setLabels:viewModel.labels];
    
    if ([self isHasReview:viewModel.productRate]) {
        _ratingContainerView.hidden = NO;
        [_starsRateView setStarscount: round([viewModel.productRate doubleValue] / 20.0)];
        _totalReviewLabel.text = [NSString stringWithFormat: @"(%@)", viewModel.totalReview];
    } else {
        _ratingContainerView.hidden = YES;
    }
    
    _productId = viewModel.productId;
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
        label.text = [NSString stringWithFormat:@"%@ ", productLabel.title];
        label.backgroundColor  = [UIColor fromHexString:productLabel.color];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1.0;
        label.layer.borderColor =  [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor tpGray].CGColor : [UIColor fromHexString:productLabel.color].CGColor;
        label.textColor = [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor lightGrayColor] : [UIColor whiteColor];
        label.font = [UIFont superMicroTheme];
        
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
    
    NSMutableArray *urls = [NSMutableArray new];
    for(ProductBadge* badge in badges){
        [urls addObject:badge.image_url];
    }
    
    [imageDownloader downloadImagesWithUrls:urls onComplete:^(NSArray<UIImage *> *images) {
        for(UIImage *image in images){
            if(image.size.width > 1){
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
                imageView.image = image;
                
                [_badgesView addArrangedSubview:imageView];
                
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(_badgesView.mas_height);
                    make.height.equalTo(_badgesView.mas_height);
                }];
            }
        }
    }];
}


- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];

    self.productPrice.text = @"Mulai dari";
    self.productPrice.font = [UIFont microTheme];
    
    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada produk" : [NSString stringWithFormat:@"%@ produk", viewModel.catalogSeller]];
     self.goldShopBadge.hidden = YES;
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeCenter];
    
    self.locationImage.hidden = YES;
    self.shopLocation.text = nil;
    _ratingContainerView.hidden = YES;
    
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}

- (BOOL) isHasReview: (NSString*) productRate {
    if ([productRate isEqualToString:@"0"] || productRate == nil) {
        return NO;
    }
    
    return YES;
}

@end
