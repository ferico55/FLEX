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
#import "SubmitReviewResult.h"
#import "ImageResult.h"

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

- (void)requestReviewValidationWithReputationID:(NSString*)reputationID
                                      productID:(NSString*)productID
                                   accuracyRate:(int)accuracyRate
                                    qualityRate:(int)qualityRate
                                        message:(NSString*)reviewMessage
                                         shopID:(NSString*)shopID
                                       serverID:(NSString*)serverID
                          hasProductReviewPhoto:(BOOL)hasProductReviewPhoto
                                 reviewPhotoIDs:(NSArray*)imageIDs
                             reviewPhotoObjects:(NSDictionary*)photos
                                      onSuccess:(void(^)(SubmitReviewResult *result))successCallback
                                      onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestUploadReviewImageWithHost:(NSString*)host
                                    data:(id)imageData
                                 imageID:(NSString*)imageID
                                   token:(NSString*)token
                               onSuccess:(void(^)(ImageResult *result))successCallback
                               onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestProductReviewSubmitWithPostKey:(NSString*)postKey
                                 fileUploaded:(NSDictionary*)fileUploaded
                                    onSuccess:(void(^)(SubmitReviewResult *result))successCallback
                                    onFailure:(void(^)(NSError *errorResult))errorCallback;

@end
