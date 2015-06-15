//
//  ProductTableViewCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModelView;

@interface ProductTableViewCell : UITableViewCell

- (void)setViewModel:(ProductModelView*)viewModel;

@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *productShop;
@property (weak, nonatomic) IBOutlet UIImageView *productThumb;

@end
