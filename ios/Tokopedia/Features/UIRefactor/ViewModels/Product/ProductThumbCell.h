//
//  ProductThumbCell.h
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

@interface ProductThumbCell : UICollectionViewCell

- (void)setCatalogViewModel:(CatalogModelView*)viewModel;
- (void) removeWishlistButton;

@property(nonatomic, weak) IBOutlet UILabel* productName;
@property(nonatomic, weak) IBOutlet UILabel* productPrice;
@property(nonatomic, weak) IBOutlet UILabel* shopName;
@property(nonatomic, weak) IBOutlet UILabel* shopLocation;
@property(nonatomic, weak) IBOutlet UILabel* catalogPriceLabel;
@property(nonatomic, weak) IBOutlet UIImageView* locationIcon;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grosirIconLocation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *luckyIconLocation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceWidthConstraint;

@property (strong, nonatomic) IBOutlet OAStackView *badgesView;
@property (strong, nonatomic) IBOutlet OAStackView *labelsView;

@property (strong, nonatomic) UIViewController *parentViewController;
@property (weak, nonatomic) id<ProductCellDelegate> delegate;
@property (strong, nonatomic) ProductModelView *viewModel;

@property (strong, nonatomic) NSString *searchTerm;

@end
