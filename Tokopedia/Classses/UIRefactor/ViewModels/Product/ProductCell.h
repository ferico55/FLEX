//
//  ProductTableViewCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDStackView.h"
@class ProductModelView;
@class CatalogModelView;

@interface ProductCell : UICollectionViewCell

- (void)setViewModel:(ProductModelView*)viewModel;
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
@property (weak, nonatomic) IBOutlet UILabel *grosirLabel;
@property (weak, nonatomic) IBOutlet UILabel *preorderLabel;
@property (weak, nonatomic) IBOutlet UILabel *catalogPriceLabel;

@property (strong, nonatomic) IBOutlet TKPDStackView *badgesView;

@end
