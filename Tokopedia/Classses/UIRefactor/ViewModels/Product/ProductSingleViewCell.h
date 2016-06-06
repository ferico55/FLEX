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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceWidthConstraint;


- (void)setViewModel:(ProductModelView*)viewModel;
- (void)setCatalogViewModel:(CatalogModelView*)viewModel;

@end
