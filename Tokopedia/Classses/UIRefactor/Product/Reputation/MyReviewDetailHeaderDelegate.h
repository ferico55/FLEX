//
//  MyReviewDetailHeaderDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailMyInboxReputation.h"

@protocol MyReviewDetailHeaderDelegate <NSObject>
- (void)didTapRevieweeName:(NSString*)name;
- (void)didTapRevieweeReputation:(NSString*)role;
- (void)didTapNotSatisfiedSmiley;
- (void)didTapNeutralSmiley;
- (void)didTapSatisfiedSmiley;
- (void)didTapLockedSmiley;
- (void)didTapReviewerScore;
@end
