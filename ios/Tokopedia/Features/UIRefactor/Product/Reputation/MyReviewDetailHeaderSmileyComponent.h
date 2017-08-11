//
//  MyReviewDetailHeaderSmileyComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailMyInboxReputation.h"
#import "MyReviewDetailHeader.h"
#import <ComponentKit/ComponentKit.h>

@interface MyReviewDetailHeaderSmileyComponent : CKCompositeComponent

+ (instancetype)newWithInbox:(DetailMyInboxReputation*)inbox context:(MyReviewDetailContext*)context;

- (void)getMyScore;
- (void)didTapLockedSmiley;
- (void)didTapNotSatisfiedSmiley;
- (void)didTapSatisfiedSmiley;
- (void)didTapNeutralSmiley;

@end
