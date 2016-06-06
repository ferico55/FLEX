//
//  ProductThumbCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModelView;
@class CatalogModelView;

@interface ProductThumbCell : UICollectionViewCell

- (void)setViewModel:(ProductModelView*)viewModel;
- (void)setCatalogViewModel:(CatalogModelView*)viewModel;

@property(nonatomic, weak) IBOutlet UILabel* productName;
@property(nonatomic, weak) IBOutlet UILabel* productPrice;
@property(nonatomic, weak) IBOutlet UILabel* grosirLabel;
@property(nonatomic, weak) IBOutlet UILabel* preorderLabel;
@property(nonatomic, weak) IBOutlet UILabel* shopName;
@property(nonatomic, weak) IBOutlet UILabel* shopLocation;
@property(nonatomic, weak) IBOutlet UIImageView* locationIcon;
@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grosirIconLocation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *luckyIconLocation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceWidthConstraint;


@end
