//
//  DetailReviewReputationComponentDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"

@protocol DetailReputationReviewComponentDelegate <NSObject>
- (void)didTapProductWithReview:(DetailReputationReview*)review;
- (void)didTapToGiveReview:(DetailReputationReview*)review;
- (void)didTapToGiveResponse:(DetailReputationReview*)review;
- (void)didTapToSkipReview:(DetailReputationReview*)review;
- (void)didTapToEditReview:(DetailReputationReview*)review;
- (void)didTapToReportReview:(DetailReputationReview*)review;
- (void)didTapToDeleteResponse:(DetailReputationReview*)review;
- (void)didTapAttachedImages:(DetailReputationReview*)review withIndex:(NSInteger)index;
@end
