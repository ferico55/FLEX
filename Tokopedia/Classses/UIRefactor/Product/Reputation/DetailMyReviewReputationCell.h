//
//  DetailMyReviewReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#define CPaddingTopBottom 8
#define CDiameterImage 50
#define CHeightContentStar 35
#define CHeightContentAction 40

@class DetailReviewReputationViewModel;
@interface CustomBtnSkip : UIButton
@property (nonatomic) BOOL isLewati, isLapor;
@end


@protocol detailMyReviewReputationCell
- (void)actionUbah:(id)sender;
- (void)actionBeriReview:(id)sender;
- (void)actionProduct:(id)sender;
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url;
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription;
- (void)goToImageViewerImages:(NSArray*)images atIndexImage:(NSInteger)index atIndexPath:(NSIndexPath*)indexPath;
@end

@interface DetailMyReviewReputationCell : UITableViewCell<TTTAttributedLabelDelegate>
{
    IBOutlet UIView *viewContent, *viewContentStar, *viewContentAction, *viewKualitas, *viewAkurasi, *viewSeparatorContentAction;
    IBOutlet UIView *viewAttachedImages;
    IBOutlet UIButton *btnProduct, *btnKomentar;
    IBOutlet CustomBtnSkip *btnUbah;
    TTTAttributedLabel *lblDesc;
    IBOutlet UIImageView *imgProduct;
    IBOutlet UILabel *lblKualitas, *lblAkurasi, *lblDate, *labelInfoSkip;
    IBOutletCollection(UIImageView) NSArray *arrImgKualitas, *arrImgAkurasi;
    IBOutletCollection(UIImageView) NSArray *attachedImages;
    NSIndexPath *indexPath;
}
@property (nonatomic, strong) NSString *strRole;
@property (nonatomic, unsafe_unretained) id<detailMyReviewReputationCell> delegate;

- (UIButton *)getBtnKomentar;
- (UIButton *)getBtnUbah;
- (UIButton *)getBtnProduct;
- (void)setHiddenAction:(BOOL)hidden;
- (void)setHiddenRating:(BOOL)hidden;
- (IBAction)actionUbah:(id)sender;
- (IBAction)actionBeriReview:(id)sender;
- (IBAction)actionProduct:(id)sender;
- (TTTAttributedLabel *)getLabelDesc;
- (void)setView:(DetailReviewReputationViewModel *)viewModel;
- (void)setUnClickViewAction;
@end
