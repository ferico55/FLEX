//
//  ProductTableViewCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDStackView.h"
#import "ProductModelView.h"
#import <OAStackView/OAStackView.h>
@class ProductModelView;
@class CatalogModelView;

@protocol ProductCellDelegate <NSObject>
- (void) changeWishlistForProductId:(NSString*)productId withStatus:(bool) isOnWishlist;
@end

@interface ProductCell : UICollectionViewCell

- (void)setCatalogViewModel:(CatalogModelView*)viewModel;

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productShop;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *luckyBadgePosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preorderPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *badgesConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shopLocation;
@property (weak, nonatomic) IBOutlet UIButton *buttonWishlist;
@property (weak, nonatomic) IBOutlet UILabel *catalogPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonWishlistExpander;
@property (weak, nonatomic) IBOutlet UIImageView *iconOvalWhite;

@property (strong, nonatomic) IBOutlet OAStackView *badgesView;
@property (strong, nonatomic) IBOutlet OAStackView *labelsView;
@property (strong, nonatomic) UIViewController *parentViewController;
@property (weak, nonatomic) id<ProductCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceLabelTopConstraint;
@property (strong, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (strong, nonatomic) IBOutlet UIView *discountView;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceLabelWidthConstraint;
@property (strong, nonatomic) NSString* applinks;
@property (strong, nonatomic) ProductModelView *viewModel;

- (void) removeWishlistButton;
- (void) updateLayout;
@end
