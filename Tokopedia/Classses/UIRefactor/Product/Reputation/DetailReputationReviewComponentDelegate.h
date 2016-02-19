//
//  DetailReviewReputationComponentDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"

@protocol DetailReputationReviewComponentDelegate <NSObject>
- (void)didTapHeaderWithReview:(DetailReputationReview*)review;
- (void)didTapToGiveReview:(DetailReputationReview*)review;
@end
