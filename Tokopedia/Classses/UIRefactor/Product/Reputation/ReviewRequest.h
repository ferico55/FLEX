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
#import "TotalLikeDislikePost.h"
#import "LikeDislikePostResult.h"

@interface ReviewRequest : NSObject
- (void) requestReviewLikeDislikesWithId:(NSString *)reviewId
                                  shopId:(NSString *)shopId
                               onSuccess:(void(^)(TotalLikeDislike* totalLikeDislike))successCallback
                               onFailure:(void(^)(NSError* errorResult)) errorCallback;

- (void) actionLikeWithReviewId:(NSString *)reviewId
                         shopId:(NSString *)shopId
                      productId:(NSString *)productId
                         userId:(NSString *)userId
                      onSuccess:(void(^)(LikeDislikePostResult* likeDislikePostResult))successCallback
                      onFailure:(void(^)(NSError* errorResult)) errorCallback;

- (void) actionDislikeWithReviewId:(NSString *)reviewId
                         shopId:(NSString *)shopId
                      productId:(NSString *)productId
                         userId:(NSString *)userId
                      onSuccess:(void(^)(LikeDislikePostResult* likeDislikePostResult))successCallback
                      onFailure:(void(^)(NSError* errorResult)) errorCallback;

- (void) actionCancelLikeDislikeWithReviewId:(NSString *)reviewId
                         shopId:(NSString *)shopId
                      productId:(NSString *)productId
                         userId:(NSString *)userId
                      onSuccess:(void(^)(LikeDislikePostResult* likeDislikePostResult))successCallback
                      onFailure:(void(^)(NSError* errorResult)) errorCallback;
@end
