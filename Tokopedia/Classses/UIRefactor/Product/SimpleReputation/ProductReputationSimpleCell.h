//
//  ProductReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"
#import "TTTAttributedLabel.h"
#import "DetailReputationReview.h"

@class DetailReviewReputationViewModel;
@class ReviewList;

@protocol ProductReputationSimpleDelegate <NSObject>
-(void)showMoreDidTappedInIndexPath:(NSIndexPath*)indexPath;
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


@property (strong, nonatomic) IBOutlet TTTAttributedLabel *reputationMessageLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationBuyerLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationDateLabel;
@property(nonatomic, weak) IBOutlet UIButton *productNameButton;

@property(nonatomic, weak) IBOutlet EDStarRating *reputationStarQualityRating;
@property(nonatomic, weak) IBOutlet EDStarRating *reputationStarAccuracyRating;

@property(nonatomic, weak) IBOutlet UIImageView *reputationBuyerImage;
@property(nonatomic, weak) id<ProductReputationSimpleDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *leftBorderView;
@property (strong, nonatomic) IBOutlet UIButton *showMoreButton;
@property(strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet UIView *reviewImageAttachmentView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *reviewImageAttachmentPictures;


//put flag in cell not in viewmodel because everyone uses different viewmodel and entity
//cannot put flag in all viewmodel variations!
@property BOOL isHelpful;

- (void)setReputationModelView:(DetailReviewReputationViewModel*)viewModel;
- (void)setShopReputationModelView:(DetailReputationReview*)viewModel;


@end
