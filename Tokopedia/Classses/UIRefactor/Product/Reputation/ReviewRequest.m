//
//  ReviewRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ReviewRequest.h"
#import "TokopediaNetworkManager.h"
#import "LikeDislike.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "TotalLikeDislikePost.h"
#import "TotalLikeDislike.h"

#define ACTION_LIKE_REQUEST 1
#define ACTION_DISLIKE_REQUEST 2
#define ACTION_CANCEL_LIKE_OR_DISLIKE_REQUEST 3

@interface ReviewRequest()<TokopediaNetworkManagerDelegate>
@end

@implementation ReviewRequest{
    TokopediaNetworkManager *likeDislikeCountNetworkManager;
    TokopediaNetworkManager *actionLikeNetworkManager;
    TokopediaNetworkManager *actionDislikeNetworkManager;
    TokopediaNetworkManager *actionCancelLikeDislikeNetworkManager;
}

- (id)init{
    self = [super init];
    if(self){
        likeDislikeCountNetworkManager = [TokopediaNetworkManager new];
        actionLikeNetworkManager = [TokopediaNetworkManager new];
        actionDislikeNetworkManager = [TokopediaNetworkManager new];
        actionCancelLikeDislikeNetworkManager = [TokopediaNetworkManager new];
    }
    return self;
}

#pragma mark - Public Function
-(void)requestReviewLikeDislikesWithId:(NSString *)reviewId shopId:(NSString *)shopId onSuccess:(void (^)(TotalLikeDislike *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    likeDislikeCountNetworkManager.isParameterNotEncrypted = NO;
    likeDislikeCountNetworkManager.isUsingHmac = YES;
    [likeDislikeCountNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                                  path:@"/v4/product/get_like_dislike_review.pl"
                                                method:RKRequestMethodGET
                                             parameter:@{@"review_ids" : reviewId,
                                                         @"shop_id" : shopId}
                                               mapping:[LikeDislike mapping]
                                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                 LikeDislike *obj = [result objectForKey:@""];
                                                 successCallback((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]);
                                             } onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}

-(void)actionLikeWithReviewId:(NSString *)reviewId shopId:(NSString *)shopId productId:(NSString *)productId userId:(NSString *)userId onSuccess:(void (^)(LikeDislikePostResult *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    
    actionLikeNetworkManager.isParameterNotEncrypted = NO;
    actionLikeNetworkManager.isUsingHmac = YES;
    [actionLikeNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                                   path:@"/v4/action/review/like_dislike_review.pl"
                                                 method:RKRequestMethodGET
                                              parameter:@{@"product_id"  : productId,
                                                          @"review_id"   : reviewId,
                                                          @"shop_id"     : shopId,
                                                          @"user_id"     : userId,
                                                          @"like_status" : @(ACTION_LIKE_REQUEST)
                                                          }
                                                mapping:[LikeDislikePost mapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                  NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                  LikeDislikePost *obj = [result objectForKey:@""];
                                                  successCallback(obj.data);
                                              } onFailure:^(NSError *errorResult) {
                                                  errorCallback(errorResult);
                                              }];
}

-(void)actionDislikeWithReviewId:(NSString *)reviewId shopId:(NSString *)shopId productId:(NSString *)productId userId:(NSString *)userId onSuccess:(void (^)(LikeDislikePostResult *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    
    actionDislikeNetworkManager.isParameterNotEncrypted = NO;
    actionDislikeNetworkManager.isUsingHmac = YES;
    [actionDislikeNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                            path:@"/v4/action/review/like_dislike_review.pl"
                                          method:RKRequestMethodGET
                                       parameter:@{@"product_id"  : productId,
                                                   @"review_id"   : reviewId,
                                                   @"shop_id"     : shopId,
                                                   @"user_id"     : userId,
                                                   @"like_status" : @(ACTION_DISLIKE_REQUEST)
                                                   }
                                         mapping:[LikeDislikePost mapping]
                                       onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                           NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                           LikeDislikePost *obj = [result objectForKey:@""];
                                           successCallback(obj.data);
                                       } onFailure:^(NSError *errorResult) {
                                           errorCallback(errorResult);
                                       }];
}

-(void)actionCancelLikeDislikeWithReviewId:(NSString *)reviewId shopId:(NSString *)shopId productId:(NSString *)productId userId:(NSString *)userId onSuccess:(void (^)(LikeDislikePostResult *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    
    actionCancelLikeDislikeNetworkManager.isParameterNotEncrypted = NO;
    actionCancelLikeDislikeNetworkManager.isUsingHmac = YES;
    [actionCancelLikeDislikeNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                                         path:@"/v4/action/review/like_dislike_review.pl"
                                                       method:RKRequestMethodGET
                                                    parameter:@{@"product_id"  : productId,
                                                                @"review_id"   : reviewId,
                                                                @"shop_id"     : shopId,
                                                                @"user_id"     : userId,
                                                                @"like_status" : @(ACTION_CANCEL_LIKE_OR_DISLIKE_REQUEST)
                                                                }
                                                      mapping:[LikeDislikePost mapping]
                                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                        LikeDislikePost *obj = [result objectForKey:@""];
                                                        successCallback(obj.data);
                                                    } onFailure:^(NSError *errorResult) {
                                                        errorCallback(errorResult);
                                                    }];
}


@end
