//
//  ProductSingleViewCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OAStackView/OAStackView.h>
#import "TKPDStackView.h"
#import "ProductCell.h"
@class ProductModelView;
@class CatalogModelView;

@interface ProductSingleViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *productInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *catalogPriceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productShop;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel* shopLocation;
@property (weak, nonatomic) IBOutlet UIImageView* locationIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* grosirPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceWidthConstraint;

@property (strong, nonatomic) IBOutlet OAStackView *badgesView;
@property (strong, nonatomic) IBOutlet OAStackView *labelsView;

@property (strong, nonatomic) UIViewController *parentViewController;
@property (weak, nonatomic) id<ProductCellDelegate> delegate;
@property (strong, nonatomic) ProductModelView *viewModel;

@property (strong, nonatomic) NSString *searchTerm;

- (void)setCatalogViewModel:(CatalogModelView*)viewModel;
- (void) removeWishlistButton;

@end
