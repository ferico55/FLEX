//
//  ProductReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTattributedLabel.h"
#import "DetailReputationReview.h"

#define CPaddingTopBottom 8
#define CHeightDate 15
#define CheightImage 50
#define CHeightContentRate 40
#define CHeightContentAction 40

@class ViewLabelUser;
@protocol productReputationDelegate <NSObject>
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription;
- (void)actionRate:(id)sender;
- (void)actionLike:(id)sender;
- (void)actionDisLike:(id)sender;
- (void)actionChat:(id)sender;
- (void)actionMore:(id)sender;
- (void)didTapAttachedImage:(UITapGestureRecognizer*)sender;
@end



@interface ProductReputationCell : UITableViewCell
{
    IBOutlet UIView *viewContent, *lineSeparatorDesc, *viewStarKualitas, *viewStarAkurasi, *viewSeparatorKualitas, *viewContentLoad, *viewContentRating, *viewContentAction;
    IBOutlet UIView *viewAttachedImages;
    IBOutlet UIImageView *imageProfile;
    IBOutlet ViewLabelUser *viewLabelUser;
    IBOutlet UIButton *btnRateEmoji, *btnLike, *btnDislike, *btnChat, *btnMore;
    IBOutlet UILabel *lblPercentageRage, *lblDateDesc, *lblKualitas, *lblAkurasi;
    UILabel *lblDesc;
    IBOutlet UIActivityIndicatorView *actLoading;
    
    BOOL isProductCell;//flag is used to product data
    IBOutletCollection(UIImageView) NSArray *arrImageKualitas, *arrImageAkurasi;
    IBOutletCollection(UIImageView) NSArray *arrAttachedImages;
}
@property (nonatomic, unsafe_unretained) id<productReputationDelegate> delegate;
@property BOOL hasAttachedImages;

- (void)setImageKualitas:(int)total;
- (void)setImageAkurasi:(int)total;
- (void)initProductCell;
- (UIImageView *)getProductImage;
- (void)setLabelProductName:(NSString *)strProductName;
- (void)setHiddenRating:(BOOL)hidden;
- (void)setHiddenAction:(BOOL)hidden;
- (TTTAttributedLabel *)getLabelDesc;
- (void)setHiddenViewLoad:(BOOL)isLoading;
- (UIImageView *)getImageProfile;
- (UIButton *)getBtnRateEmoji;
- (UIButton *)getBtnLike;
- (UIButton *)getBtnDisLike;
- (UIButton *)getBtnChat;
- (UIButton *)getBtnMore;
- (UILabel *)getLabelProductName;
- (UILabel *)getLabelPercentageRate;
- (void)setLabelUser:(NSString *)strUser withUserLabel:(NSString *)strUserLabel;
- (void)setPercentage:(NSString *)strPercentage;
- (void)setLabelDate:(NSString *)strDate;
- (void)setDescription:(NSString *)strDescription;
- (IBAction)actionRate:(id)sender;
- (ViewLabelUser *)getLabelUser;
- (UIView *)getViewSeparatorProduct;
- (UIView *)getViewContent;
- (UIView *)getViewContentAction;
- (UIView *)getViewSeparatorKualitas;
- (IBAction)actionLike:(id)sender;
- (IBAction)actionDisLike:(id)sender;
- (IBAction)actionChat:(id)sender;
- (IBAction)actionMore:(id)sender;
- (void)enableLikeButton;
- (void)disableLikeButton;
- (void)enableDislikeButton;
- (void)disableDislikeButton;
- (void)resetLikeDislikeButton;
- (void)enableTouchLikeDislikeButton;
- (void)disableTouchLikeDislikeButton;
- (void)setAttachedImages:(NSArray*)attachedImages;
@end
