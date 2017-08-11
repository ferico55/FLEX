//
//  MyReviewDetailHeaderSmileyDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

@protocol MyReviewDetailHeaderSmileyDelegate <NSObject>
- (void)didTapNotSatisfiedSmiley:(DetailMyInboxReputation*)inbox;
- (void)didTapNeutralSmiley:(DetailMyInboxReputation*)inbox;
- (void)didTapSatisfiedSmiley:(DetailMyInboxReputation*)inbox;
- (void)didTapLockedSmiley;
- (void)didTapReviewerScore:(DetailMyInboxReputation*)inbox;
@end

