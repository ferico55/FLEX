//
//  MyReviewDetailHeaderSmileyDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

@protocol MyReviewDetailHeaderSmileyDelegate <NSObject>
- (void)didTapNotSatisfiedSmiley;
- (void)didTapNeutralSmiley;
- (void)didTapSatisfiedSmiley;
- (void)didTapLockedSmiley;
- (void)didTapReviewerScore:(DetailMyInboxReputation*)inbox;
@end

