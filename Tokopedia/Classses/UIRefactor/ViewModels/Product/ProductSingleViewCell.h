//
//  ProductSingleViewCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModelView;
@class CatalogModelView;

@interface ProductSingleViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *productInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *catalogPriceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productShop;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (weak, nonatomic) IBOutlet UILabel* shopLocation;
@property (weak, nonatomic) IBOutlet UILabel* grosirLabel;
@property (weak, nonatomic) IBOutlet UILabel* preorderLabel;
@property (weak, nonatomic) IBOutlet UIImageView* locationIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* luckyIconPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* grosirPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceWidthConstraint;


- (void)setViewModel:(ProductModelView*)viewModel;
- (void)setCatalogViewModel:(CatalogModelView*)viewModel;

@end
