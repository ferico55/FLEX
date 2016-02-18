//
//  ReviewRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailReputationReview.h"
#import "TotalLikeDislike.h"

@protocol ReviewRequestDelegate <NSObject>
- (void) didReceiveReviewLikeDislikes:(TotalLikeDislike*)totalLikeDislike;
- (void) didReceiveProductReview:(DetailReputationReview*)detailReputationReview;
@end


@interface ReviewRequest : NSObject
-(void)requestReviewLikeDislikesWithId:(NSString*)reviewId shopId:(NSString*)shopId;

@property (weak, nonatomic) id<ReviewRequestDelegate> delegate;
@end
