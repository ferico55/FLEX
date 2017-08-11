//
//  GeneralProductCollectionViewCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 5/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModelView.h"

@interface GeneralProductCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productShop;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *goldShopBadge;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;

- (void)setViewModel:(ProductModelView *)productModelView;
@end
