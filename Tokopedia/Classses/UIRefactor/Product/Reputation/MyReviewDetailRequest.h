//
//  MyReviewDetailRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailMyInboxReputation.h"
#import "DetailReputationReview.h"
#import "MyReviewReputationResult.h"
#import "SkipReviewResult.h"
#import "SkipReview.h"
#import "ResponseCommentResult.h"
#import "GeneralAction.h"

@protocol MyReviewDetailRequestDelegate <NSObject>

- (void)didReceiveReviewListing:(MyReviewReputationResult*)myReviews;
- (void)didSkipReview:(SkipReviewResult*)skippedReview;
- (void)didFailSkipReview:(SkipReview*)skipReview;
- (void)didDeleteReputationReviewResponse:(ResponseCommentResult*)response;
- (void)didInsertReputation:(GeneralAction*)action;

@end

@interface MyReviewDetailRequest : NSObject
- (void)requestGetListReputationReviewWithDetail:(DetailMyInboxReputation*)rep autoRead:(NSString*)autoRead getDataFromMasterInServer:(NSString*)val;
- (void)requestSkipReviewWithDetail:(DetailReputationReview*)rep;
- (void)requestDeleteReputationReviewResponse:(DetailReputationReview*)review;
- (void)requestInsertReputation:(DetailMyInboxReputation*)inbox withScore:(NSString*)score;
- (void)cancelAllOperations;

@property (weak, nonatomic) id<MyReviewDetailRequestDelegate> delegate;

@end
