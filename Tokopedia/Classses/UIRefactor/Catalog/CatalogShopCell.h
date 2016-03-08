//
//  CatalogShopCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CatalogShopDelegate <NSObject>
- (void)actionContentStar:(id)sender;
- (void)tableViewCell:(UITableViewCell *)cell didSelectShopAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectProductAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectBuyButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectOtherProductAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CatalogShopCell : UITableViewCell
{
    IBOutlet UIView *viewContentStar, *expandViewContentStar;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *seeOtherProducts;
@property (weak, nonatomic) IBOutlet UIImageView *goldMerchantBadge;
@property (weak, nonatomic) IBOutlet UIImageView *luckyMerchantBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthGoldMerchant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSpaceLuckyMerchant;

@property (weak, nonatomic) IBOutlet UIView *masking;

@property (weak, nonatomic) id<CatalogShopDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

//@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stars;
@property (strong, nonatomic) IBOutlet UIView *reputationBadgeView;
@property (strong, nonatomic) IBOutlet UIImageView *reputationBadge;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *reputationBadgeViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *reputationBadgeLeadingConstraint;


- (void)setTagContentStar:(int)tag;
@end