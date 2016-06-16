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
#import "DetailMyInboxReputation.h"
#import "InboxReputationResult.h"
#import "MyReviewReputationResult.h"
#import "SubmitReviewResult.h"
#import "ImageResult.h"
#import "SkipReviewResult.h"
#import "ResponseCommentResult.h"
#import "GeneralActionResult.h"
#import "ReviewResult.h"
#import "GeneralAction.h"

@interface ReviewRequest : NSObject
- (void)requestReviewLikeDislikesWithId:(NSString *)reviewId
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

- (void)requestGetInboxReputationWithNavigation:(NSString*)navigation
                                           page:(NSNumber*)page
                                         filter:(NSString*)filter
                                        keyword:(NSString*)keyword
                                      onSuccess:(void(^)(InboxReputationResult *inboxReputationResult))successCallback
                                      onFailure:(void(^)(NSError *errorResult))errorCallback;

- (int)getNextPageFromUri:(NSString*)uri;

- (void)requestGetListReputationReviewWithReputationID:(NSString*)reputationID
                                     reputationInboxID:(NSString*)reputationInboxID
                                     getDataFromMaster:(NSString*)getDataFromMaster
                                                  role:(NSString*)role
                                              autoRead:(NSString*)autoRead
                                             onSuccess:(void(^)(MyReviewReputationResult* result))successCallback
                                             onFailure:(void(^)(NSError* errorResult))errorCallback;

- (void)requestSubmitReviewWithImageWithReputationID:(NSString *)reputationID
                                           productID:(NSString *)productID
                                        accuracyRate:(int)accuracyRate
                                         qualityRate:(int)qualityRate
                                             message:(NSString *)reviewMessage
                                              shopID:(NSString *)shopID
                                            serverID:(NSString *)serverID
                               hasProductReviewPhoto:(BOOL)hasProductReviewPhoto
                                      reviewPhotoIDs:(NSArray *)imageIDs
                                  reviewPhotoObjects:(NSDictionary *)photos
                                      imagesToUpload:(NSDictionary *)imagesToUpload
                                               token:(NSString*)token
                                                host:(NSString*)host
                                           onSuccess:(void (^)(SubmitReviewResult *result))successCallback
                                           onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestEditReviewWithImageWithReviewID:(NSString*)reviewID
                                     productID:(NSString*)productID
                                  accuracyRate:(int)accuracyRate
                                   qualityRate:(int)qualityRate
                                  reputationID:(NSString*)reputationID
                                       message:(NSString*)reviewMessage
                                        shopID:(NSString*)shopID
                         hasProductReviewPhoto:(BOOL)hasProductReviewPhoto
                                reviewPhotoIDs:(NSArray*)imageIDs
                            reviewPhotoObjects:(NSDictionary*)photos
                                imagesToUpload:(NSDictionary*)imagesToUpload
                                         token:(NSString*)token
                                          host:(NSString*)host
                                     onSuccess:(void(^)(SubmitReviewResult *result))successCallback
                                     onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestSkipProductReviewWithProductID:(NSString*)productID
                                 reputationID:(NSString*)reputationID
                                       shopID:(NSString*)shopID
                                    onSuccess:(void(^)(SkipReviewResult *result))successCallback
                                    onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestInsertReputationReviewResponseWithReputationID:(NSString*)reputationID
                                              responseMessage:(NSString*)responseMessage
                                                     reviewID:(NSString*)reviewID
                                                       shopID:(NSString*)shopID
                                                    onSuccess:(void(^)(ResponseCommentResult *result))successCallback
                                                    onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestDeleteReputationReviewResponseWithReputationID:(NSString*)reputationID
                                                     reviewID:(NSString*)reviewID
                                                       shopID:(NSString*)shopID
                                                    onSuccess:(void(^)(ResponseCommentResult *result))successCallback
                                                    onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestInsertReputationWithReputationID:(NSString*)reputationID
                                           role:(NSString*)role
                                          score:(NSString*)score
                                      onSuccess:(void(^)(GeneralActionResult *result))successCallback
                                      onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestGetProductReviewWithProductID:(NSString*)productID
                                  monthRange:(NSNumber*)monthRange
                                        page:(NSNumber*)page
                                shopAccuracy:(NSNumber*)shopAccuracy
                                 shopQuality:(NSNumber*)shopQuality
                                  shopDomain:(NSString*)shopDomain
                                   onSuccess:(void(^)(ReviewResult *result))successCallback
                                   onFailure:(void(^)(NSError *error))errorCallback;

- (int)requestGetProductReviewNextPageFromUri:(NSString*)uri;

- (void)requestReportReviewWithReviewID:(NSString*)reviewID
                                 shopID:(NSString*)shopID
                            textMessage:(NSString*)textMessage
                              onSuccess:(void(^)(GeneralAction *action))successCallback
                              onFailure:(void(^)(NSError *error))errorCallback;

@end
