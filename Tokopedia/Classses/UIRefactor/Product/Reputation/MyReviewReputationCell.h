//
//  MyReviewReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewLabelUser;
@class MyReviewReputationViewModel, MyReviewReputation;

@protocol MyReviewReputationDelegate
- (void)actionInvoice:(id)sender;
- (void)actionFooter:(id)sender;
- (void)actionReviewRate:(id)sender;
- (void)actionLabelUser:(id)sender;
- (void)actionFlagReview:(id)sender;
@end



@interface MyReviewReputationCell : UITableViewCell
{
    IBOutlet UIView *viewContent, *viewFlagReadUnread;
    IBOutlet UIImageView *imageProfile, *imageFlagReview;
    IBOutlet UIButton *btnInvoice, *btnFooter, *btnReview;
    IBOutlet ViewLabelUser *labelUser;
    UIActivityIndicatorView *activityRating;
    UIImage *imageSmile, *imageSad, *imageNetral, *imageNeutral, *imageQuestionGray, *imageQuestionBlue, *imageQSmile;
    IBOutlet NSLayoutConstraint *constraintLeftViewContent, *constraintRightViewContent, *constraintTopViewContent, *cosntraintBottomViewContent;
}
@property (nonatomic, unsafe_unretained) id<MyReviewReputationDelegate> delegate;

- (void)setLeftViewContentContraint:(int)n;
- (void)setBottomViewContentContraint:(int)n;
- (void)setTopViewContentContraint:(int)n;
- (void)setRightViewContentContraint:(int)n;
- (void)isLoadInView:(BOOL)isLoad withView:(UIView *)view;
- (ViewLabelUser *)getLabelUser;
- (UIView *)getViewContent;
- (UIButton *)getBtnInvoice;
- (UIButton *)getBtnFooter;
- (UIButton *)getBtnReview;
- (UIImageView *)getImageFlagReview;
- (NSLayoutConstraint *)getTopViewContentConstraint;
- (IBAction)actionInvoice:(id)sender;
- (IBAction)actionFooter:(id)sender;
- (IBAction)actionReview:(id)sender;
- (void)setView:(MyReviewReputationViewModel *)object;
@end
