//
//  DetailReviewReputationComponentDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"

@protocol DetailReputationReviewComponentDelegate <NSObject>
- (void)didTapToGiveReview:(DetailReputationReview*)review;
- (void)didTapToGiveResponse:(DetailReputationReview*)review;
- (void)didTapToSkipReview:(DetailReputationReview*)review;
- (void)didTapToEditReview:(DetailReputationReview*)review atView:(UIView*)view;
- (void)didTapToReportReview:(DetailReputationReview*)review atView:(UIView*)view;
- (void)didTapToDeleteResponse:(DetailReputationReview*)review atView:(UIView*)view;
- (void)didTapAttachedImages:(DetailReputationReview*)review withIndex:(NSInteger)index;
- (void)didTapRevieweeReputation:(id)sender onReview:(DetailReputationReview*)review atView:(UIView*)view;

@optional
- (void)didTapProductWithReview:(DetailReputationReview*)review;
@end
