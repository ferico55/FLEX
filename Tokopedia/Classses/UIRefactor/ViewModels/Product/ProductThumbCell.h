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

@end
