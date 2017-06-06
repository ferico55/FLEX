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
#import "Tokopedia-Swift.h"
#import "QueueImageDownloader.h"
#import "Tokopedia-Swift.h"
#import "StarsRateView.h"

@interface ProductThumbCell()
@property (strong, nonatomic) IBOutlet UILabel *totalReviewLabel;
@property (strong, nonatomic) IBOutlet StarsRateView *qualityRateValue;
@property (strong, nonatomic) IBOutlet UIView *ratingContainerView;
@end

@implementation ProductThumbCell {
    QueueImageDownloader* imageDownloader;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    // using dynamic layout attributes for iOS 8 & 9 is making layout bug such as cell overlaping, not proportional cell size, and product being not shown. So, I decide to do this restriction
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
        CGRect frame = layoutAttributes.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.size.height = ceil(size.height);
        layoutAttributes.frame = frame;
        return layoutAttributes;
    }
    return layoutAttributes;
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
    self.grosirIconLocation.constant = viewModel.isProductPreorder ? 7 : -50;
    self.luckyIconLocation.constant = viewModel.isGoldShopProduct ? 7 : -19;
    [_productName setLineBreakMode:NSLineBreakByTruncatingTail];


    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [self setBadges:viewModel.badges];
    [self setLabels:viewModel.labels];
    
    if(!viewModel.productShop || [viewModel.productShop isEqualToString:@"0"]) {
        [self.shopName setHidden:YES];
        [self.shopLocation setHidden:YES];
    }
    else {
        [self.shopName setHidden: NO];
        [self.shopLocation setHidden:NO];
    }
    
    if (![viewModel.productRate isEqualToString: @"0"] && viewModel.productRate != nil) {
        [_ratingContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(16);
        }];
        [_qualityRateValue setStarscount:round([viewModel.productRate doubleValue] / 20.0)];
        [_totalReviewLabel setText:[NSString stringWithFormat:@"(%@)", viewModel.totalReview]];
    } else {
        [_ratingContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)setLabels:(NSArray<ProductLabel*>*) labels {
    for(UIView* subview in _labelsView.arrangedSubviews) {
        [_labelsView removeArrangedSubview:subview];
    }
    
    if (labels.count > 0) {

        [_labelsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(16);
        }];
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
            label.layer.borderColor =  [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor tpGray].CGColor : [UIColor fromHexString:productLabel.color].CGColor;
            label.textColor = [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor tpDisabledBlackText] : [UIColor whiteColor];
            label.font = [UIFont superMicroTheme];
            [label sizeToFit];
            
            [_labelsView addArrangedSubview:label];
        }
    } else {
        [_labelsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
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
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFit];
    
    self.locationIcon.hidden = YES;
    self.shopLocation.text = nil;

    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.productPrice.text = @"Mulai dari :";
    self.productPrice.font = [UIFont microTheme];
    
    self.productName.numberOfLines = 2;
    self.productName.font = [UIFont smallThemeMedium];
    self.productName.text = viewModel.catalogName;
    _ratingContainerView.hidden = YES;
    
    self.productPriceWidthConstraint.constant = -50;
    [self.shopName setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada penjual" : [NSString stringWithFormat:@"%@ Penjual", viewModel.catalogSeller]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}

@end
