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
@end



@interface MyReviewReputationCell : UITableViewCell
{
    IBOutlet UIView *viewContent, *viewFlagReadUnread;
    IBOutlet UIImageView *imageProfile, *imageFlagReview;
    IBOutlet UIButton *btnInvoice, *btnFooter, *btnReview;
    IBOutlet ViewLabelUser *labelUser;
    UIActivityIndicatorView *activityRating;
}
@property (nonatomic, unsafe_unretained) id<MyReviewReputationDelegate> delegate;

- (void)isLoadInView:(BOOL)isLoad withView:(UIView *)view;
- (ViewLabelUser *)getLabelUser;
- (UIButton *)getBtnInvoice;
- (UIButton *)getBtnFooter;
- (UIButton *)getBtnReview;
- (IBAction)actionInvoice:(id)sender;
- (IBAction)actionFooter:(id)sender;
- (IBAction)actionReview:(id)sender;
- (void)setView:(MyReviewReputationViewModel *)object;
@end
