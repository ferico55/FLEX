//
//  ProductReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTattributedLabel.h"

#define CPaddingTopBottom 8
#define CHeightDate 15
#define CHeightViewStar 18
#define CHeightButton 30
#define CheightImage 50
#define CHeightContentRate 30
#define CHeightContentAction 35

@class ViewLabelUser;
@protocol productReputationDelegate <NSObject>
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription;
- (void)actionRate:(id)sender;
- (void)actionLike:(id)sender;
- (void)actionDisLike:(id)sender;
- (void)actionChat:(id)sender;
- (void)actionMore:(id)sender;
@end



@interface ProductReputationCell : UITableViewCell
{
    IBOutlet UIView *viewContent, *lineSeparatorDesc, *viewStarKualitas, *viewStarAkurasi, *viewSeparatorKualitas, *viewContentLoad, *viewContentRating, *viewContentAction;
    IBOutlet UIImageView *imageProfile;
    IBOutlet ViewLabelUser *viewLabelUser;
    IBOutlet UIButton *btnRateEmoji, *btnLike, *btnDislike, *btnChat, *btnMore;
    IBOutlet UILabel *lblPercentageRage, *lblDateDesc, *lblKualitas, *lblAkurasi;
    TTTAttributedLabel *lblDesc;
    IBOutlet UIActivityIndicatorView *actLoading;
    
    BOOL isProductCell;//flag is used to product data
    IBOutletCollection(UIImageView) NSArray *arrImageKualitas, *arrImageAkurasi;
}
@property (nonatomic, unsafe_unretained) id<productReputationDelegate> delegate;

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
- (void)setLabelUser:(NSString *)strUser withTag:(int)tag;
- (void)setPercentage:(NSString *)strPercentage;
- (void)setLabelDate:(NSString *)strDate;
- (void)setDescription:(NSString *)strDescription;
- (IBAction)actionRate:(id)sender;
- (UIView *)getViewContent;
- (UIView *)getViewContentAction;
- (UIView *)getViewSeparatorKualitas;
- (IBAction)actionLike:(id)sender;
- (IBAction)actionDisLike:(id)sender;
- (IBAction)actionChat:(id)sender;
- (IBAction)actionMore:(id)sender;
@end
