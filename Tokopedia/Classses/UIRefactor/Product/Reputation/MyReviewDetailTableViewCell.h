//
//  MyReviewDetailTableViewCell.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GIVE_REVIEW_CELL_IDENTIFIER @"GiveReviewCellIdentifier"
#define REVIEW_DETAIL_CELL_IDENTIFIER @"ReviewDetailCellIdentifier"
#define SKIPPED_REVIEW_CELL_IDENTIFIER @"SkippedReviewCellIdentifier"
#define NO_REVIEW_GIVEN_CELL_IDENTIFIER @"NoReviewGivenCellIdentifier"

#pragma mark - Review Detail Delegate
@protocol MyReviewDetailTableViewCellDelegate <NSObject>
- (void)giveReviewAtIndexPath:(NSIndexPath*)indexPath;
- (void)skipReviewAtIndexPath:(NSIndexPath*)indexPath;
- (void)goToProductDetailAtIndexPath:(NSIndexPath*)indexPath;
- (void)editReviewAtIndexPath:(NSIndexPath*)indexPath;
- (void)goToImageViewerAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface MyReviewDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet id<MyReviewDetailTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewTimestampLabel;

@property (weak, nonatomic) IBOutlet UIButton *giveReviewButton;
@property (weak, nonatomic) IBOutlet UIButton *skipReviewButton;

@property (weak, nonatomic) IBOutlet UIView *reviewDetailView;
@property (weak, nonatomic) IBOutlet UIButton *editReviewButton;
@property (weak, nonatomic) IBOutlet UITextView *reviewMessageTextView;
@property (weak, nonatomic) IBOutlet UIView *attachedImagesView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImagesArray;
@property (weak, nonatomic) IBOutlet UIView *horizontalBorderView;
@property (weak, nonatomic) IBOutlet UIView *ratingDetailView;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UIView *qualityStarsView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *qualityStarsImagesArray;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UIView *accuracyStarsView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *accuracyStarsImagesArray;

@property (weak, nonatomic) IBOutlet UIView *horizontalBorder;

@property (weak, nonatomic) IBOutlet UIView *reviewCommentView;
@property (weak, nonatomic) IBOutlet UIImageView *shopImage;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UIView *shopMedalView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *medalImagesArray;
@property (weak, nonatomic) IBOutlet UITextView *sellersCommentTextView;
@property (weak, nonatomic) IBOutlet UILabel *sellersCommentTimestampLabel;

@property (weak, nonatomic) IBOutlet UILabel *reviewIsSkippedLabel;
@property NSIndexPath *indexPath;

+ (id)newCellWithIdentifier:(NSString*)identifier;
- (void)setMedalWithLevel:(NSString*)level set:(NSString*)set;

@end
