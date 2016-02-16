//
//  ProductTableViewCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModelView;
@class CatalogModelView;

@interface ProductCell : UICollectionViewCell

- (void)setViewModel:(ProductModelView*)viewModel;
- (void)setCatalogViewModel:(CatalogModelView*)viewModel;
- (void)lalala;

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productShop;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintGoldBadge;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintSpaceGoldBadge;

@end
