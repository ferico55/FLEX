//
//  CatalogShopCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CatalogShopDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)cell didSelectShopAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectProductAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectBuyButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectOtherProductAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CatalogShopCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *seeOtherProducts;

@property (weak, nonatomic) IBOutlet UIView *masking;

@property (strong, nonatomic) id<CatalogShopDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end