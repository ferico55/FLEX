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
#import "DetailMyInboxReputation.h"
#import "InboxReputationResult.h"
#import "MyReviewReputationResult.h"

@interface ReviewRequest : NSObject
- (void)requestReviewLikeDislikesWithId:(NSString *)reviewId
                                 shopId:(NSString *)shopId
                              onSuccess:(void(^)(TotalLikeDislike* totalLikeDislike))successCallback
                              onFailure:(void(^)(NSError* errorResult)) errorCallback;

- (void)requestGetInboxReputationWithNavigation:(NSString*)navigation
                                           page:(NSNumber*)page
                                         filter:(NSString*)filter
                                      onSuccess:(void(^)(InboxReputationResult *inboxReputationResult))successCallback
                                      onFailure:(void(^)(NSError *errorResult))errorCallback;

- (int)getNextPageFromUri:(NSString*)uri;

- (void)requestGetListReputationReviewWithReputationID:(NSString*)reputationID
                                     reputationInboxID:(NSString*)reputationInboxID
                                          isUsingRedis:(NSString*)isUsingRedis
                                                  role:(NSString*)role
                                              autoRead:(NSString*)autoRead
                                             onSuccess:(void(^)(MyReviewReputationResult* result))successCallback
                                             onFailure:(void(^)(NSError* errorResult))errorCallback;

@end
