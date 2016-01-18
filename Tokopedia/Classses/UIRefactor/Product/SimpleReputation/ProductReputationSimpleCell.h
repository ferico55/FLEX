//
//  ProductReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@class DetailReviewReputationViewModel;
@class ReviewList;

@protocol ProductReputationSimpleDelegate <NSObject>

@end


@interface ProductReputationSimpleCell : UITableViewCell {
    UIImage *_starActiveImage;
    UIImage *_starInactiveImage;
    
    NSString *_productID;
    NSString *_productImage;
    NSString *_productName;
    NSString *_productPrice;
    NSString *_productShopName;
}

@property(nonatomic, weak) IBOutlet UIView *reputationMessageView;
@property(nonatomic, weak) IBOutlet UIView *reputationBuyerView;
@property(nonatomic, weak) IBOutlet UIView *listReputationView;
@property(nonatomic, weak) IBOutlet UIView *reputationStarQualityView;
@property(nonatomic, weak) IBOutlet UIView *reputationStarAccuracyView;
@property(nonatomic, weak) IBOutlet UIView *productView;

@property(nonatomic, weak) IBOutlet UILabel *reputationMessageLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationBuyerLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationDateLabel;
@property(nonatomic, weak) IBOutlet UIButton *productNameButton;

@property(nonatomic, weak) IBOutlet EDStarRating *reputationStarQualityRating;
@property(nonatomic, weak) IBOutlet EDStarRating *reputationStarAccuracyRating;

@property(nonatomic, weak) IBOutlet UIImageView *reputationBuyerImage;
@property(nonatomic, weak) id<ProductReputationSimpleDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *leftBorderView;

- (void)setReputationModelView:(DetailReviewReputationViewModel*)viewModel;
- (void)setShopReputationModelView:(ReviewList*)viewModel;

@end
