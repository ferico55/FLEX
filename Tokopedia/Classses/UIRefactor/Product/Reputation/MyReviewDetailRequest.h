//
//  MyReviewDetailRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyReviewReputationResult.h"
#import "SkipReviewResult.h" 

@protocol MyReviewDetailRequestDelegate <NSObject>

- (void)didReceiveReviewListing:(MyReviewReputationResult*)myReviews;
- (void)didSkipReview:(SkipReviewResult*)skippedReview;

@end

@interface MyReviewDetailRequest : NSObject

@property (weak, nonatomic) id<MyReviewDetailRequestDelegate> delegate;

@end
